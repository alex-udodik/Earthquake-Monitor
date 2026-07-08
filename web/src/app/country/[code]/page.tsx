import Link from "next/link";
import { ArrowLeft } from "lucide-react";
import { fetchCountrySummary, fetchTimeSeries } from "@/lib/upstash";
import { StatCard } from "@/components/country/StatCard";
import {
  OverTimeChart,
  MagnitudeDistributionChart,
  MonthlyActivityChart,
} from "@/components/country/Charts";
import { timeAgo } from "@/lib/time";

export default async function CountryDetailPage({
  params,
}: {
  params: Promise<{ code: string }>;
}) {
  const { code } = await params;
  const lower = code.toLowerCase();

  const [summary, series] = await Promise.all([
    fetchCountrySummary(lower).catch(() => null),
    fetchTimeSeries(lower, "daily").catch(() => []),
  ]);

  const name = summary?.country ?? code.toUpperCase();

  return (
    <main className="mx-auto min-h-[100dvh] w-full max-w-3xl px-4 py-4">
      {/* Header */}
      <header className="mb-6 flex items-center gap-3">
        <Link
          href="/"
          className="rounded-md p-1 text-white/80 hover:bg-white/10 hover:text-white"
          aria-label="Back to dashboard"
        >
          <ArrowLeft className="h-5 w-5" />
        </Link>
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img
          src={`/flags/${lower}.svg`}
          alt=""
          width={32}
          height={24}
          className="h-6 w-8 rounded-sm object-cover"
        />
        <h1 className="text-xl font-bold text-white">{name}</h1>
      </header>

      {summary ? (
        <div className="space-y-6">
          <div className="space-y-2">
            <StatCard label="Total Earthquakes" value={summary.count.toLocaleString()} />
            <StatCard
              label="Average Magnitude"
              value={summary.avgMag?.toFixed(1) ?? "—"}
            />
            <StatCard
              label="Strongest Recorded"
              value={summary.maxMag?.toFixed(1) ?? "—"}
            />
            <StatCard
              label="Most Recent Quake"
              value={timeAgo(summary.mostRecent)}
            />
          </div>

          <OverTimeChart data={series} />
          <MagnitudeDistributionChart data={series} />
          <MonthlyActivityChart data={series} />
        </div>
      ) : (
        <p className="mt-16 text-center text-white/50">
          No data found for this country yet.
        </p>
      )}
    </main>
  );
}
