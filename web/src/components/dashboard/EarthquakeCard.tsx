"use client";

import { Earthquake } from "@/lib/types";
import { magnitudeColor } from "@/lib/magnitude";
import { timeAgo } from "@/lib/time";
import { cn } from "@/lib/utils";

interface Props {
  quake: Earthquake;
  highlighted?: boolean;
  onClick?: () => void;
}

// Port of the card in frontend/client/lib/ui/dashboard/cardlist.dart:
// magnitude-tinted background, region title, magnitude + relative time.
export function EarthquakeCard({ quake, highlighted, onClick }: Props) {
  const { properties: p } = quake;
  const color = magnitudeColor(p.mag);

  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        "w-full rounded-xl border border-white/10 p-3 text-left transition-all",
        "hover:brightness-110 focus:outline-none focus:ring-2 focus:ring-em-accent",
        highlighted && "ring-2 ring-yellow-300 shadow-[0_0_15px_4px_rgba(253,224,71,0.6)]",
      )}
      style={{ backgroundColor: `${color}59` }} // ~35% opacity
    >
      <div className="truncate font-semibold text-white">{p.flynnRegion}</div>
      <div className="mt-1 text-sm text-white/90">
        Magnitude: {p.mag.toFixed(1)}
      </div>
      <div className="text-sm text-white/70">Occurred: {timeAgo(p.time)}</div>
    </button>
  );
}
