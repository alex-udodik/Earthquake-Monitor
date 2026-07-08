"use client";

import { Settings } from "lucide-react";
import { useEarthquakes, DEFAULT_FILTERS } from "@/context/EarthquakeProvider";
import { Button } from "@/components/ui/button";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetFooter,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";

function Field({
  label,
  children,
}: {
  label: string;
  children: React.ReactNode;
}) {
  return (
    <label className="block space-y-1">
      <span className="text-sm text-white/70">{label}</span>
      {children}
    </label>
  );
}

const numberInput =
  "w-full rounded-md border border-white/15 bg-black/30 px-2 py-1 text-sm text-white";

/** Filter panel — ports settings_popup.dart + the filter logic in map.dart. */
export function SettingsButton() {
  const { filters, setFilters } = useEarthquakes();

  return (
    <Sheet>
      <SheetTrigger
        aria-label="Filters"
        render={
          <Button
            size="icon"
            variant="secondary"
            className="absolute right-4 top-4 z-[1000] bg-em-panel/90 text-white shadow-lg hover:bg-em-panel"
          />
        }
      >
        <Settings className="h-5 w-5" />
      </SheetTrigger>
      <SheetContent className="z-[1100] bg-em-panel text-white">
        <SheetHeader>
          <SheetTitle className="text-white">Filters</SheetTitle>
          <SheetDescription>
            Filter which earthquakes appear on the map and list.
          </SheetDescription>
        </SheetHeader>

        <div className="space-y-4 px-4">
          <div className="grid grid-cols-2 gap-3">
            <Field label="Min magnitude">
              <input
                type="number"
                step="0.1"
                min={0}
                max={10}
                className={numberInput}
                value={filters.minMagnitude}
                onChange={(e) =>
                  setFilters({ minMagnitude: Number(e.target.value) })
                }
              />
            </Field>
            <Field label="Max magnitude">
              <input
                type="number"
                step="0.1"
                min={0}
                max={10}
                className={numberInput}
                value={filters.maxMagnitude}
                onChange={(e) =>
                  setFilters({ maxMagnitude: Number(e.target.value) })
                }
              />
            </Field>
            <Field label="Min depth (km)">
              <input
                type="number"
                step="1"
                min={0}
                className={numberInput}
                value={filters.minDepth}
                onChange={(e) =>
                  setFilters({ minDepth: Number(e.target.value) })
                }
              />
            </Field>
            <Field label="Max depth (km)">
              <input
                type="number"
                step="1"
                min={0}
                className={numberInput}
                value={filters.maxDepth}
                onChange={(e) =>
                  setFilters({ maxDepth: Number(e.target.value) })
                }
              />
            </Field>
          </div>

          <Field label="Region contains">
            <input
              type="text"
              placeholder="Any"
              className={numberInput}
              value={filters.region === "Any" ? "" : filters.region}
              onChange={(e) =>
                setFilters({ region: e.target.value || "Any" })
              }
            />
          </Field>
        </div>

        <SheetFooter>
          <Button
            variant="outline"
            className="text-black"
            onClick={() => setFilters(DEFAULT_FILTERS)}
          >
            Reset
          </Button>
        </SheetFooter>
      </SheetContent>
    </Sheet>
  );
}
