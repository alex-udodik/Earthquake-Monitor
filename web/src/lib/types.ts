// Ported from frontend/client/lib/models/earthquake.dart
// The backend feeds GeoJSON-shaped earthquake events. JSON is snake_case;
// we normalize into typed camelCase objects.

export interface EarthquakeProperties {
  sourceId: string | null;
  sourceCatalog: string | null;
  lastUpdate: string | null;
  time: string | null;
  flynnRegion: string;
  lat: number;
  lon: number;
  depth: number;
  evType: string | null;
  auth: string | null;
  mag: number;
  magType: string | null;
  unid: string | null;
  displayName: string;
  state: string;
  country: string;
  countryCode: string;
  region: string;
  subregion: string;
}

export interface Earthquake {
  action: string;
  id: string;
  lat: number;
  lon: number;
  properties: EarthquakeProperties;
}

function num(v: unknown, fallback = 0): number {
  const n = typeof v === "string" ? parseFloat(v) : (v as number);
  return typeof n === "number" && !Number.isNaN(n) ? n : fallback;
}

function str(v: unknown, fallback = "Unknown"): string {
  return v == null || v === "" ? fallback : String(v);
}

/**
 * Normalize a raw `data` object (the `details.data` payload from the socket /
 * REST API) into a typed Earthquake. Mirrors Earthquake.fromJson in the
 * Flutter client.
 */
export function normalizeEarthquake(raw: any): Earthquake | null {
  if (!raw || !raw.data) return null;
  const data = raw.data;
  const p = data.properties ?? {};
  const coords: number[] = data.geometry?.coordinates ?? [];

  const lat = num(p.lat, coords[1]);
  const lon = num(p.lon, coords[0]);

  return {
    action: str(raw.action, "create"),
    id: str(data.id, ""),
    lat,
    lon,
    properties: {
      sourceId: p.source_id ?? null,
      sourceCatalog: p.source_catalog ?? null,
      lastUpdate: p.lastupdate ?? null,
      time: p.time ?? null,
      flynnRegion: str(p.flynn_region ?? p.display_name, "Unknown region"),
      lat,
      lon,
      depth: num(p.depth, coords[2]),
      evType: p.evtype ?? null,
      auth: p.auth ?? null,
      mag: num(p.mag),
      magType: p.magtype ?? null,
      unid: p.unid ?? null,
      displayName: str(p.display_name),
      state: str(p.state),
      country: str(p.country),
      countryCode: str(p.country_code),
      region: str(p.region),
      subregion: str(p.subregion),
    },
  };
}

/**
 * Parse a socket/REST `message` payload. It is an array where each item is
 * either `{ details: { action, data } }` (wrapped) or a raw `{ action, data }`.
 * Accepts a stringified array too.
 */
export function parseEarthquakeList(message: unknown): Earthquake[] {
  let list: any[] = [];
  if (typeof message === "string") {
    try {
      list = JSON.parse(message);
    } catch {
      return [];
    }
  } else if (Array.isArray(message)) {
    list = message;
  }

  const out: Earthquake[] = [];
  for (const item of list) {
    const source = item?.details ?? item;
    const eq = normalizeEarthquake(source);
    if (eq && eq.id) out.push(eq);
  }
  return out;
}

// ── Country detail types ────────────────────────────────────────────────
export interface CountrySummary {
  count: number;
  avgMag: number;
  maxMag: number;
  avgDepth: number;
  mostRecent: string;
  country: string;
  country_code: string;
}

export interface TimeSeriesPoint {
  timestamp: string;
  count: number;
  avgMag?: number;
  maxMag?: number;
}
