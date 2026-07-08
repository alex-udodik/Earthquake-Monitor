"use client";

import "leaflet/dist/leaflet.css";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import {
  MapContainer,
  TileLayer,
  GeoJSON,
  Marker,
  Popup,
  useMap,
} from "react-leaflet";
import MarkerClusterGroup from "react-leaflet-cluster";
import L from "leaflet";
import type { Feature, GeoJsonObject } from "geojson";
import { useEarthquakes } from "@/context/EarthquakeProvider";
import { magnitudeColor, magnitudeRadius } from "@/lib/magnitude";
import { timeAgo } from "@/lib/time";

// Build a pulsating, magnitude-colored marker icon (port of pulsating_marker.dart).
function markerIcon(mag: number): L.DivIcon {
  const size = Math.round(magnitudeRadius(mag) * 2);
  const color = magnitudeColor(mag);
  return L.divIcon({
    className: "",
    html: `<div class="eq-marker" style="width:${size}px;height:${size}px;background:${color}">${mag.toFixed(1)}</div>`,
    iconSize: [size, size],
    iconAnchor: [size / 2, size / 2],
  });
}

function clusterIcon(cluster: { getChildCount(): number }): L.DivIcon {
  const count = cluster.getChildCount();
  const size = count < 10 ? 34 : count < 100 ? 42 : 50;
  return L.divIcon({
    html: `<div class="eq-cluster">${count}</div>`,
    className: "",
    iconSize: [size, size],
  });
}

// Registers a pan handler so sidebar cards can fly the map to a quake.
function PanController() {
  const map = useMap();
  const { registerPanHandler } = useEarthquakes();
  useEffect(() => {
    registerPanHandler((lat, lon) =>
      map.flyTo([lat, lon], 6, { duration: 1.2 }),
    );
    return () => registerPanHandler(null);
  }, [map, registerPanHandler]);
  return null;
}

// Country polygons; clicking one opens its detail page.
function CountryLayer() {
  const router = useRouter();
  const [data, setData] = useState<GeoJsonObject | null>(null);

  useEffect(() => {
    let active = true;
    fetch("/geo/country_polygons_geo_low.json")
      .then((r) => r.json())
      .then((json) => {
        if (active) setData(json);
      })
      .catch(() => {});
    return () => {
      active = false;
    };
  }, []);

  if (!data) return null;

  return (
    <GeoJSON
      data={data}
      style={() => ({
        color: "#f44336",
        weight: 0.5,
        fillColor: "#f44336",
        fillOpacity: 0.04,
      })}
      onEachFeature={(feature: Feature, layer) => {
        layer.on({
          mouseover: (e) =>
            e.target.setStyle({ fillOpacity: 0.18, color: "#64ffda" }),
          mouseout: (e) =>
            e.target.setStyle({ fillOpacity: 0.04, color: "#f44336" }),
          click: () => {
            const code = feature.properties?.iso_a2 as string | undefined;
            if (code && code !== "-99") {
              router.push(`/country/${code.toLowerCase()}`);
            }
          },
        });
      }}
    />
  );
}

export default function MapView() {
  const { filtered } = useEarthquakes();

  return (
    <MapContainer
      center={[20, 0]}
      zoom={3}
      minZoom={2}
      worldCopyJump
      maxBounds={[
        [-85, -200],
        [85, 200],
      ]}
      style={{ height: "100%", width: "100%" }}
    >
      <TileLayer
        url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
        subdomains={["a", "b", "c", "d"]}
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; <a href="https://carto.com/attributions">CARTO</a>'
      />
      <CountryLayer />
      <PanController />
      <MarkerClusterGroup
        chunkedLoading
        maxClusterRadius={45}
        iconCreateFunction={clusterIcon}
        showCoverageOnHover={false}
      >
        {filtered.map((q) => (
          <Marker
            key={q.id}
            position={[q.lat, q.lon]}
            icon={markerIcon(q.properties.mag)}
          >
            <Popup>
              <div className="min-w-40">
                <div className="font-semibold text-em-accent">
                  {q.properties.flynnRegion}
                </div>
                <div className="mt-1 text-sm">
                  Magnitude: {q.properties.mag.toFixed(1)}
                </div>
                <div className="text-sm">
                  Depth: {q.properties.depth.toFixed(1)} km
                </div>
                <div className="text-sm text-muted-foreground">
                  {timeAgo(q.properties.time)}
                </div>
              </div>
            </Popup>
          </Marker>
        ))}
      </MarkerClusterGroup>
    </MapContainer>
  );
}
