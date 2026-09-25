import { CalendarClock, IndianRupee, QrCode, type LucideIcon } from "lucide-react";
import { BrandMark } from "./brand-mark";
import { WeightPlate } from "./weight-plate";

interface Station {
  icon: LucideIcon;
  title: string;
  caption: string;
}

const STATIONS: readonly Station[] = [
  { icon: QrCode, title: "Check-ins", caption: "QR attendance at the door" },
  { icon: CalendarClock, title: "Renewals", caption: "Expiry alerts before they lapse" },
  { icon: IndianRupee, title: "Payments", caption: "Dues, invoices and revenue" },
];

/** Left half of the login screen: brand story, shown from lg up. */
export function BrandPanel() {
  return (
    <section
      aria-labelledby="brand-heading"
      className="relative hidden overflow-hidden border-r border-brand-line p-12 lg:flex lg:flex-col lg:justify-between xl:p-16 [@media(max-height:760px)]:py-8"
    >
      <div className="pointer-events-none absolute -left-40 top-1/4 size-[520px] rounded-full bg-brand-blaze/20 blur-[140px]" />
      <WeightPlate className="animate-plate-spin pointer-events-none absolute -bottom-56 -right-72 size-[620px] opacity-70" />

      <div className="relative">
        <BrandMark />
      </div>

      <div className="relative my-auto max-w-xl py-8">
        <p className="mb-6 font-mono text-xs [@media(max-height:760px)]:mb-4 uppercase tracking-[0.3em] text-brand-volt">
          Gym management · built for the floor
        </p>
        <h1
          id="brand-heading"
          className="font-display text-7xl font-extrabold uppercase leading-[0.85] tracking-tight text-brand-text xl:text-8xl [@media(max-height:760px)]:text-6xl"
        >
          Every member.
          <br />
          Every visit.
          <br />
          <span className="text-brand-blaze">Every rupee.</span>
        </h1>
        <p className="mt-8 max-w-md text-base leading-relaxed text-brand-muted [@media(max-height:680px)]:hidden">
          Memberships, attendance, trainers and payments — run the whole gym floor from one
          dashboard.
        </p>
      </div>

      <ul className="relative grid max-w-xl grid-cols-3 divide-x divide-brand-line border-y border-brand-line bg-brand-ink/70 backdrop-blur-sm [@media(max-height:640px)]:hidden">
        {STATIONS.map(({ icon: Icon, title, caption }, index) => (
          <li key={title} className="px-5 py-5 first:pl-0">
            <span className="font-mono text-[11px] text-brand-muted">0{index + 1}</span>
            <div className="mt-2 flex items-center gap-2 text-brand-text">
              <Icon className="size-4 text-brand-volt" />
              <span className="font-display text-xl font-semibold uppercase tracking-wide">
                {title}
              </span>
            </div>
            <p className="mt-1 text-xs leading-snug text-brand-muted">{caption}</p>
          </li>
        ))}
      </ul>
    </section>
  );
}
