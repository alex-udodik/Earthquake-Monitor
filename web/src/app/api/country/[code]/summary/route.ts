import { NextResponse } from "next/server";
import { fetchCountrySummary } from "@/lib/upstash";

/**
 * Proxies the Upstash country summary so the bearer token stays server-side.
 */
export async function GET(
  _req: Request,
  { params }: { params: Promise<{ code: string }> },
) {
  const { code } = await params;
  try {
    const summary = await fetchCountrySummary(code);
    if (!summary) {
      return NextResponse.json({ error: "Not found" }, { status: 404 });
    }
    return NextResponse.json(summary);
  } catch (err) {
    return NextResponse.json(
      { error: err instanceof Error ? err.message : "Fetch failed" },
      { status: 500 },
    );
  }
}
