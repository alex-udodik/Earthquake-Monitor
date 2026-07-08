import { formatDistanceToNow } from "date-fns";

/** "5 minutes ago" style relative time. Mirrors Flutter's timeago usage. */
export function timeAgo(iso: string | null | undefined): string {
  if (!iso) return "Unknown";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "Unknown";
  return formatDistanceToNow(d, { addSuffix: true });
}

/** Local timestamp badge shown above the sidebar list. */
export function formattedNow(): string {
  const now = new Date();
  return now.toLocaleString(undefined, {
    month: "2-digit",
    day: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}
