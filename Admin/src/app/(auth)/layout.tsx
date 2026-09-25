import type { ReactNode } from "react";
import { Barlow_Condensed } from "next/font/google";

// Condensed athletic display face, loaded only for the auth screens.
const barlowCondensed = Barlow_Condensed({
  variable: "--font-barlow-condensed",
  subsets: ["latin"],
  weight: ["600", "800"],
  display: "swap",
});

export default function AuthLayout({ children }: { children: ReactNode }) {
  return <div className={`${barlowCondensed.variable} flex flex-1 flex-col`}>{children}</div>;
}
