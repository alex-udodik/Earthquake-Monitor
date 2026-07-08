"use client";

import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { TimeSeriesPoint } from "@/lib/types";
import { magnitudeColor } from "@/lib/magnitude";

const AXIS = "rgba(255,255,255,0.55)";
const GRID = "rgba(255,255,255,0.08)";
const TEAL = "#64ffda";

function ChartCard({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <section className="space-y-3">
      <h2 className="text-lg font-semibold text-white">{title}</h2>
      <div className="rounded-xl bg-em-panel/60 p-3">{children}</div>
    </section>
  );
}

function EmptyState() {
  return (
    <div className="flex h-44 items-center justify-center rounded-lg bg-white/5 text-sm text-white/40">
      No data available
    </div>
  );
}

// Dark tooltip shared by all charts.
function DarkTooltip({ active, payload, label }: any) {
  if (!active || !payload?.length) return null;
  return (
    <div className="rounded-lg border border-white/10 bg-[#1a1f28] px-3 py-2 text-xs text-white shadow-lg">
      <div className="mb-1 text-white/60">{label}</div>
      {payload.map((p: any) => (
        <div key={p.name} className="font-medium">
          {p.name}: {typeof p.value === "number" ? p.value.toLocaleString() : p.value}
        </div>
      ))}
    </div>
  );
}

function monthYear(ts: string): string {
  const d = new Date(ts);
  return `${d.getMonth() + 1}/${d.getFullYear()}`;
}

// ── Earthquakes over time (single-series area) ──────────────────────────
export function OverTimeChart({ data }: { data: TimeSeriesPoint[] }) {
  const chartData = [...data]
    .reverse()
    .map((p) => ({ label: monthYear(p.timestamp), count: p.count ?? 0 }));

  return (
    <ChartCard title="Earthquakes Over Time">
      {chartData.length === 0 ? (
        <EmptyState />
      ) : (
        <ResponsiveContainer width="100%" height={200}>
          <AreaChart data={chartData} margin={{ top: 8, right: 8, bottom: 0, left: -12 }}>
            <defs>
              <linearGradient id="overTimeFill" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor={TEAL} stopOpacity={0.5} />
                <stop offset="100%" stopColor={TEAL} stopOpacity={0} />
              </linearGradient>
            </defs>
            <CartesianGrid stroke={GRID} vertical={false} />
            <XAxis
              dataKey="label"
              tick={{ fill: AXIS, fontSize: 11 }}
              tickLine={false}
              axisLine={{ stroke: GRID }}
              minTickGap={24}
            />
            <YAxis
              tick={{ fill: AXIS, fontSize: 11 }}
              tickLine={false}
              axisLine={false}
              width={40}
            />
            <Tooltip content={<DarkTooltip />} cursor={{ stroke: GRID }} />
            <Area
              type="monotone"
              dataKey="count"
              name="Earthquakes"
              stroke={TEAL}
              strokeWidth={2}
              fill="url(#overTimeFill)"
              dot={false}
              activeDot={{ r: 4 }}
            />
          </AreaChart>
        </ResponsiveContainer>
      )}
    </ChartCard>
  );
}

// ── Magnitude distribution (histogram by floored avg magnitude) ─────────
export function MagnitudeDistributionChart({
  data,
}: {
  data: TimeSeriesPoint[];
}) {
  const histogram = new Map<number, number>();
  for (const p of data) {
    if (p.avgMag == null) continue;
    const bucket = Math.floor(p.avgMag);
    histogram.set(bucket, (histogram.get(bucket) ?? 0) + 1);
  }
  const chartData = [...histogram.entries()]
    .sort((a, b) => a[0] - b[0])
    .map(([bucket, count]) => ({
      label: `${bucket}–${bucket + 1}`,
      bucket,
      count,
    }));

  return (
    <ChartCard title="Magnitude Distribution">
      {chartData.length === 0 ? (
        <EmptyState />
      ) : (
        <ResponsiveContainer width="100%" height={200}>
          <BarChart data={chartData} margin={{ top: 8, right: 8, bottom: 0, left: -12 }}>
            <CartesianGrid stroke={GRID} vertical={false} />
            <XAxis
              dataKey="label"
              tick={{ fill: AXIS, fontSize: 11 }}
              tickLine={false}
              axisLine={{ stroke: GRID }}
            />
            <YAxis
              tick={{ fill: AXIS, fontSize: 11 }}
              tickLine={false}
              axisLine={false}
              width={40}
            />
            <Tooltip content={<DarkTooltip />} cursor={{ fill: "rgba(255,255,255,0.05)" }} />
            <Bar dataKey="count" name="Days" radius={[4, 4, 0, 0]} maxBarSize={40}>
              {chartData.map((d) => (
                <Cell key={d.bucket} fill={magnitudeColor(d.bucket)} />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      )}
    </ChartCard>
  );
}

// ── Monthly activity (counts aggregated by month) ───────────────────────
export function MonthlyActivityChart({ data }: { data: TimeSeriesPoint[] }) {
  const byMonth = new Map<string, number>();
  for (const p of data) {
    const key = monthYear(p.timestamp);
    byMonth.set(key, (byMonth.get(key) ?? 0) + (p.count ?? 0));
  }
  const chartData = [...byMonth.entries()]
    .map(([label, count]) => ({ label, count }))
    .slice(-12);

  return (
    <ChartCard title="Monthly Activity (Last Year)">
      {chartData.length === 0 ? (
        <EmptyState />
      ) : (
        <ResponsiveContainer width="100%" height={200}>
          <BarChart data={chartData} margin={{ top: 8, right: 8, bottom: 0, left: -12 }}>
            <CartesianGrid stroke={GRID} vertical={false} />
            <XAxis
              dataKey="label"
              tick={{ fill: AXIS, fontSize: 11 }}
              tickLine={false}
              axisLine={{ stroke: GRID }}
              minTickGap={16}
            />
            <YAxis
              tick={{ fill: AXIS, fontSize: 11 }}
              tickLine={false}
              axisLine={false}
              width={40}
            />
            <Tooltip content={<DarkTooltip />} cursor={{ fill: "rgba(255,255,255,0.05)" }} />
            <Bar
              dataKey="count"
              name="Earthquakes"
              fill="#FF9800"
              radius={[4, 4, 0, 0]}
              maxBarSize={40}
            />
          </BarChart>
        </ResponsiveContainer>
      )}
    </ChartCard>
  );
}
