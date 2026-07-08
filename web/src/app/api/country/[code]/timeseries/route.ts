import { NextResponse } from "next/server";
import { fetchTimeSeries } from "@/lib/upstash";

const ALLOWED_INTERVALS = new Set(["daily", "weekly", "monthly"]);

/**
 * Proxies the Upstash country time-series. Key: <cc>_<interval>.
 */
export async function GET(
  req: Request,
  { params }: { params: Promise<{ code: string }> },
) {
  const { code } = await params;
  const interval = new URL(req.url).searchParams.get("interval") ?? "daily";
  if (!ALLOWED_INTERVALS.has(interval)) {
    return NextResponse.json({ error: "Bad interval" }, { status: 400 });
  }
  try {
    const series = await fetchTimeSeries(code, interval);
    return NextResponse.json(series);
  } catch (err) {
    return NextResponse.json(
      { error: err instanceof Error ? err.message : "Fetch failed" },
      { status: 500 },
    );
  }
}
