"use client";

import dynamic from "next/dynamic";
import { ChevronUp } from "lucide-react";
import { EarthquakeSidebar } from "./EarthquakeSidebar";
import { SettingsButton } from "./SettingsButton";
import {
  Sheet,
  SheetContent,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";

// Leaflet needs `window`, so the map is client-only.
const MapView = dynamic(() => import("./MapView"), {
  ssr: false,
  loading: () => <div className="h-full w-full bg-em-canvas" />,
});

export function Dashboard() {
  return (
    <div className="relative h-[100dvh] w-full overflow-hidden md:flex md:gap-2 md:p-2">
      {/* Map (single instance) */}
      <div className="relative h-full w-full overflow-hidden md:flex-[4] md:rounded-2xl">
        <SettingsButton />
        <MapView />

        {/* Mobile: bottom sheet with the recent-earthquake list */}
        <div className="md:hidden">
          <Sheet>
            <SheetTrigger className="absolute inset-x-0 bottom-0 z-[900] flex items-center justify-center gap-2 rounded-t-2xl bg-black/85 py-3 text-sm font-medium text-white backdrop-blur">
              <ChevronUp className="h-4 w-4" />
              Recent earthquakes
            </SheetTrigger>
            <SheetContent
              side="bottom"
              className="z-[1100] h-[85dvh] border-white/10 bg-black/95 p-0"
            >
              <SheetTitle className="sr-only">Recent earthquakes</SheetTitle>
              <EarthquakeSidebar />
            </SheetContent>
          </Sheet>
        </div>
      </div>

      {/* Desktop: fixed sidebar panel */}
      <aside className="hidden md:block md:h-full md:flex-1 md:overflow-hidden md:rounded-2xl md:bg-em-panel/60">
        <EarthquakeSidebar />
      </aside>
    </div>
  );
}
