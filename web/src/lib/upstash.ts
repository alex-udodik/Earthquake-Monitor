import "server-only";
import { CountrySummary, TimeSeriesPoint } from "@/lib/types";

function config() {
  const url = process.env.UPSTASH_REST_URL;
  const token = process.env.UPSTASH_REST_TOKEN;
  if (!url || !token) throw new Error("Upstash not configured");
  return { url, token };
}

async function get(key: string): Promise<string | null> {
  const { url, token } = config();
  const res = await fetch(`${url}/get/${key}`, {
    headers: { Authorization: `Bearer ${token}` },
    cache: "no-store",
  });
  if (!res.ok) throw new Error(`Upstash error ${res.status}`);
  const body = await res.json();
  return body.result ?? null;
}

/** Country summary. Key: country_summary_<cc>. */
export async function fetchCountrySummary(
  code: string,
): Promise<CountrySummary | null> {
  const raw = await get(`country_summary_${code.toLowerCase()}`);
  return raw ? (JSON.parse(raw) as CountrySummary) : null;
}

/** Country time-series. Key: <cc>_<interval>. */
export async function fetchTimeSeries(
  code: string,
  interval = "daily",
): Promise<TimeSeriesPoint[]> {
  const raw = await get(`${code.toLowerCase()}_${interval}`);
  return raw ? (JSON.parse(raw) as TimeSeriesPoint[]) : [];
}
