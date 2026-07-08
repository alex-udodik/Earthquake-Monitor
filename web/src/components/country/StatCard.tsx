// Port of _statBlock in country_detail_screen.dart: label left, teal value right.
export function StatCard({
  label,
  value,
}: {
  label: string;
  value: string;
}) {
  return (
    <div className="flex items-center justify-between rounded-xl bg-em-panel px-4 py-3">
      <span className="text-sm text-white/70 sm:text-base">{label}</span>
      <span className="font-bold text-em-accent sm:text-lg">{value}</span>
    </div>
  );
}
