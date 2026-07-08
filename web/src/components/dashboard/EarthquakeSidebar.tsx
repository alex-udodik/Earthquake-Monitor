"use client";

import { useEffect, useState } from "react";
import { useEarthquakes, TIME_RANGES } from "@/context/EarthquakeProvider";
import { EarthquakeCard } from "./EarthquakeCard";
import { formattedNow } from "@/lib/time";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Skeleton } from "@/components/ui/skeleton";

/**
 * Scrollable list of recent earthquakes (newest first, clamped to 100), with a
 * "now" timestamp badge and the time-range selector.
 * Ports scroll_sheet.dart + cardlist.dart.
 */
export function EarthquakeSidebar() {
  const { filtered, connected, latestEventId, filters, setFilters, panTo } =
    useEarthquakes();
  const [now, setNow] = useState(formattedNow());

  // Refresh the timestamp + relative times every 10s (like the Flutter timer).
  useEffect(() => {
    const t = setInterval(() => setNow(formattedNow()), 10_000);
    return () => clearInterval(t);
  }, []);

  const list = filtered.slice(0, 100);

  return (
    <div className="flex h-full flex-col">
      <div className="flex items-center justify-between gap-2 p-3">
        <span className="rounded-full bg-black/40 px-3 py-1 text-xs font-semibold text-em-accent">
          {now}
        </span>
        <Select
          value={String(filters.timeRange)}
          onValueChange={(v) => setFilters({ timeRange: Number(v) })}
        >
          <SelectTrigger className="h-8 w-32 bg-black/40 text-white">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            {TIME_RANGES.map((r) => (
              <SelectItem key={r.hours} value={String(r.hours)}>
                {r.label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <div className="min-h-0 flex-1 space-y-2 overflow-y-auto px-3 pb-4">
        {list.length === 0 ? (
          connected ? (
            <p className="py-8 text-center text-sm text-white/50">
              No earthquakes in this range.
            </p>
          ) : (
            Array.from({ length: 6 }).map((_, i) => (
              <Skeleton key={i} className="h-20 w-full rounded-xl" />
            ))
          )
        ) : (
          list.map((q) => (
            <EarthquakeCard
              key={q.id}
              quake={q}
              highlighted={q.id === latestEventId}
              onClick={() => panTo(q.lat, q.lon)}
            />
          ))
        )}
      </div>
    </div>
  );
}
