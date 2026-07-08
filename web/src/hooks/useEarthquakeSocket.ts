"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { Earthquake, parseEarthquakeList } from "@/lib/types";

const PING_INTERVAL = 30_000;
const RECONNECT_DELAY = 5_000;

export interface SocketState {
  earthquakes: Earthquake[];
  connected: boolean;
  /** id of the most recently pushed earthquake event (for highlight/flash). */
  latestEventId: string | null;
}

/**
 * Live earthquake feed over the AWS API Gateway WebSocket.
 * Mirrors frontend/client/lib/services/socket_provider.dart:
 *  - requests initData on open
 *  - pings every 30s to keep the connection alive
 *  - reconnects on close/error
 */
export function useEarthquakeSocket(): SocketState {
  const [earthquakes, setEarthquakes] = useState<Earthquake[]>([]);
  const [connected, setConnected] = useState(false);
  const [latestEventId, setLatestEventId] = useState<string | null>(null);

  const socketRef = useRef<WebSocket | null>(null);
  const pingRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const reconnectRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const closedByUs = useRef(false);

  const connect = useCallback(() => {
    const url = process.env.NEXT_PUBLIC_WEBSOCKET_URL;
    if (!url) {
      console.error("NEXT_PUBLIC_WEBSOCKET_URL is not set");
      return;
    }

    const ws = new WebSocket(url);
    socketRef.current = ws;

    ws.onopen = () => {
      setConnected(true);
      ws.send(JSON.stringify({ action: "initData", rediskey: "" }));
      pingRef.current = setInterval(() => {
        if (ws.readyState === WebSocket.OPEN) {
          ws.send(
            JSON.stringify({
              action: "ping",
              source: "web-client",
              message: "ping to keep connection alive",
            }),
          );
        }
      }, PING_INTERVAL);
    };

    ws.onmessage = (event) => {
      try {
        const decoded = JSON.parse(event.data);
        if (!decoded || typeof decoded !== "object") return;
        if (decoded.action === "ping") return;

        if (
          decoded.action === "earthquake-event" ||
          decoded.action === "initData"
        ) {
          const list = parseEarthquakeList(decoded.message);
          if (list.length > 0) {
            setEarthquakes(list);
            if (decoded.action === "earthquake-event") {
              setLatestEventId(list[0].id);
            }
          }
        }
      } catch (err) {
        console.error("Error handling socket message:", err);
      }
    };

    const scheduleReconnect = () => {
      setConnected(false);
      if (pingRef.current) clearInterval(pingRef.current);
      if (closedByUs.current) return;
      reconnectRef.current = setTimeout(connect, RECONNECT_DELAY);
    };

    ws.onclose = scheduleReconnect;
    ws.onerror = () => ws.close();
  }, []);

  useEffect(() => {
    closedByUs.current = false;
    connect();
    return () => {
      closedByUs.current = true;
      if (pingRef.current) clearInterval(pingRef.current);
      if (reconnectRef.current) clearTimeout(reconnectRef.current);
      socketRef.current?.close();
    };
  }, [connect]);

  return { earthquakes, connected, latestEventId };
}
