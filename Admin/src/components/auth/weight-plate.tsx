import { cn } from "@/lib/utils";

interface WeightPlateProps {
  className?: string;
}

/** Decorative 20 kg bumper plate drawn as concentric rings. */
export function WeightPlate({ className }: WeightPlateProps) {
  return (
    <svg viewBox="0 0 400 400" aria-hidden="true" className={cn("text-brand-line", className)}>
      <defs>
        <path id="plate-arc-top" d="M 70 200 A 130 130 0 0 1 330 200" />
        <path id="plate-arc-bottom" d="M 60 200 A 140 140 0 0 0 340 200" />
      </defs>
      <circle cx="200" cy="200" r="196" fill="none" stroke="currentColor" strokeWidth="4" />
      <circle cx="200" cy="200" r="178" fill="none" stroke="currentColor" strokeWidth="1.5" />
      <circle cx="200" cy="200" r="104" fill="none" stroke="currentColor" strokeWidth="1.5" />
      <circle cx="200" cy="200" r="62" fill="none" stroke="var(--brand-blaze)" strokeWidth="10" />
      <circle cx="200" cy="200" r="30" fill="none" stroke="currentColor" strokeWidth="4" />
      {Array.from({ length: 24 }, (_, index) => (
        <line
          key={index}
          x1="200"
          y1="26"
          x2="200"
          y2={index % 6 === 0 ? 48 : 38}
          stroke="currentColor"
          strokeWidth="2"
          transform={`rotate(${index * 15} 200 200)`}
        />
      ))}
      <text className="fill-current font-display text-[34px] font-extrabold tracking-[0.3em]">
        <textPath href="#plate-arc-top" startOffset="50%" textAnchor="middle">
          20 KG
        </textPath>
      </text>
      <text className="fill-current font-display text-[18px] font-semibold tracking-[0.5em]">
        <textPath href="#plate-arc-bottom" startOffset="50%" textAnchor="middle">
          GYMBRAIN · OLYMPIC
        </textPath>
      </text>
    </svg>
  );
}
