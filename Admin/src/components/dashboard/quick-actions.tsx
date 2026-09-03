"use client";

import Link from "next/link";
import {
  UserPlus,
  Wallet,
  CalendarCheck,
  ClipboardPlus,
  UserSearch,
  Receipt,
} from "lucide-react";
import { Button } from "@/components/ui/button";

const ACTIONS = [
  { href: "/members?new=1", label: "Add Member", icon: UserPlus },
  { href: "/payments?new=1", label: "Collect Payment", icon: Wallet },
  { href: "/attendance", label: "Mark Attendance", icon: CalendarCheck },
  { href: "/plans?new=1", label: "Add Plan", icon: ClipboardPlus },
  { href: "/enquiries?new=1", label: "Add Enquiry", icon: UserSearch },
  { href: "/expenses?new=1", label: "Add Expense", icon: Receipt },
] as const;

type ActionHref = (typeof ACTIONS)[number]["href"];

export function QuickActions({ exclude = [] }: { exclude?: ActionHref[] }) {
  const actions = ACTIONS.filter((action) => !exclude.includes(action.href));

  return (
    <div className="flex flex-wrap gap-3">
      {actions.map(({ href, label, icon: Icon }) => (
        <Button key={href} variant="outline" nativeButton={false} render={<Link href={href} />}>
          <Icon className="h-4 w-4" />
          {label}
        </Button>
      ))}
    </div>
  );
}
