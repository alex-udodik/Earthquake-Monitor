// Ported from _getColorFromGradient in
// frontend/client/lib/ui/dashboard/cardlist.dart
// A green -> red gradient indexed by the floored magnitude, so markers and
// cards share the same color language.

const GRADIENT = [
  "#4CAF50", // green      (0)
  "#8BC34A", // lightGreen (1)
  "#FFEB3B", // yellow     (2)
  "#FFC107", // amber      (3)
  "#FF9800", // orange     (4)
  "#FF5722", // deepOrange (5)
  "#F44336", // red        (6)
  "#D32F2F", // red 700    (7)
  "#795548", // brown      (8+)
];

/** Solid hex color for a magnitude. */
export function magnitudeColor(mag: number): string {
  const clamped = Math.min(Math.max(mag, 0), 10);
  const index = Math.min(Math.floor(clamped), GRADIENT.length - 1);
  return GRADIENT[index];
}

/** Marker/card radius in px, scaled by magnitude. */
export function magnitudeRadius(mag: number): number {
  const clamped = Math.min(Math.max(mag, 0), 10);
  return 6 + clamped * 2.2;
}
