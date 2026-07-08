import { NextResponse } from "next/server";
import { Earthquake, normalizeEarthquake } from "@/lib/types";

/**
 * REST fallback for the initial earthquake list (the WebSocket also delivers
 * this via initData). Proxies the AWS API Gateway REST endpoint and normalizes
 * the { body: [ { details: { data } } ] } shape.
 */
export async function GET() {
  const url = process.env.EARTHQUAKE_API_URL;
  if (!url) {
    return NextResponse.json({ error: "API not configured" }, { status: 500 });
  }

  try {
    const res = await fetch(url, { cache: "no-store" });
    if (!res.ok) {
      return NextResponse.json(
        { error: `API error ${res.status}` },
        { status: 502 },
      );
    }
    const json = await res.json();
    const rows: any[] = json?.body ?? [];
    const out: Earthquake[] = [];
    for (const item of rows) {
      const eq = normalizeEarthquake(item?.details ?? item);
      if (eq && eq.id) out.push(eq);
    }
    return NextResponse.json(out);
  } catch (err) {
    return NextResponse.json(
      { error: err instanceof Error ? err.message : "Fetch failed" },
      { status: 500 },
    );
  }
}
