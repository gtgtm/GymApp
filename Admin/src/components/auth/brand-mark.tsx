import { Dumbbell } from "lucide-react";

export function BrandMark() {
  return (
    <div className="flex items-center gap-3">
      <span className="flex size-10 -rotate-6 items-center justify-center rounded-md bg-brand-blaze text-brand-on-blaze shadow-[0_8px_24px_-8px_var(--brand-blaze)]">
        <Dumbbell className="size-5" strokeWidth={2.5} />
      </span>
      <span className="font-display text-2xl font-extrabold uppercase tracking-wide text-brand-text">
        Gym<span className="text-brand-blaze">Brain</span>
      </span>
    </div>
  );
}
