"use client";

import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useRef,
  useState,
} from "react";
import { Earthquake } from "@/lib/types";
import { useEarthquakeSocket } from "@/hooks/useEarthquakeSocket";

export interface Filters {
  minMagnitude: number;
  maxMagnitude: number;
  minDepth: number;
  maxDepth: number;
  /** hours */
  timeRange: number;
  region: string; // "Any" or a region substring
}

export const DEFAULT_FILTERS: Filters = {
  minMagnitude: 0,
  maxMagnitude: 10,
  minDepth: 0,
  maxDepth: 700,
  timeRange: 24,
  region: "Any",
};

export const TIME_RANGES: { label: string; hours: number }[] = [
  { label: "1 Hour", hours: 1 },
  { label: "6 Hours", hours: 6 },
  { label: "24 Hours", hours: 24 },
  { label: "7 Days", hours: 24 * 7 },
  { label: "30 Days", hours: 24 * 30 },
  { label: "90 Days", hours: 24 * 90 },
];

type PanHandler = (lat: number, lon: number) => void;

interface EarthquakeContextValue {
  earthquakes: Earthquake[];
  filtered: Earthquake[];
  connected: boolean;
  latestEventId: string | null;
  filters: Filters;
  setFilters: (f: Partial<Filters>) => void;
  panTo: (lat: number, lon: number) => void;
  registerPanHandler: (h: PanHandler | null) => void;
}

const EarthquakeContext = createContext<EarthquakeContextValue | null>(null);

/** Apply the dashboard filters. Mirrors _updateMarkers in map.dart. */
function applyFilters(list: Earthquake[], f: Filters): Earthquake[] {
  const now = Date.now();
  const selectedRegion = f.region.trim().toLowerCase();
  return list.filter((q) => {
    const { mag, depth, region, time } = q.properties;
    const t = time ? new Date(time).getTime() : now;
    const hoursDiff = (now - t) / 3_600_000;
    return (
      mag >= f.minMagnitude &&
      mag <= f.maxMagnitude &&
      depth >= f.minDepth &&
      depth <= f.maxDepth &&
      hoursDiff <= f.timeRange &&
      (selectedRegion === "any" ||
        selectedRegion === "" ||
        region.toLowerCase().includes(selectedRegion))
    );
  });
}

export function EarthquakeProvider({
  children,
}: {
  children: React.ReactNode;
}) {
  const { earthquakes, connected, latestEventId } = useEarthquakeSocket();
  const [filters, setFiltersState] = useState<Filters>(DEFAULT_FILTERS);
  const panHandlerRef = useRef<PanHandler | null>(null);

  const setFilters = useCallback((f: Partial<Filters>) => {
    setFiltersState((prev) => ({ ...prev, ...f }));
  }, []);

  const registerPanHandler = useCallback((h: PanHandler | null) => {
    panHandlerRef.current = h;
  }, []);

  const panTo = useCallback((lat: number, lon: number) => {
    panHandlerRef.current?.(lat, lon);
  }, []);

  const filtered = useMemo(
    () => applyFilters(earthquakes, filters),
    [earthquakes, filters],
  );

  const value = useMemo(
    () => ({
      earthquakes,
      filtered,
      connected,
      latestEventId,
      filters,
      setFilters,
      panTo,
      registerPanHandler,
    }),
    [
      earthquakes,
      filtered,
      connected,
      latestEventId,
      filters,
      setFilters,
      panTo,
      registerPanHandler,
    ],
  );

  return (
    <EarthquakeContext.Provider value={value}>
      {children}
    </EarthquakeContext.Provider>
  );
}

export function useEarthquakes(): EarthquakeContextValue {
  const ctx = useContext(EarthquakeContext);
  if (!ctx) {
    throw new Error("useEarthquakes must be used within EarthquakeProvider");
  }
  return ctx;
}
