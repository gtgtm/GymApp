"use client";

import Link from "next/link";
import { UserPlus, Wallet, CalendarCheck, ClipboardPlus } from "lucide-react";
import { Button } from "@/components/ui/button";

const ACTIONS = [
  { href: "/members?new=1", label: "Add Member", icon: UserPlus },
  { href: "/payments?new=1", label: "Collect Payment", icon: Wallet },
  { href: "/attendance", label: "Mark Attendance", icon: CalendarCheck },
  { href: "/plans?new=1", label: "Add Plan", icon: ClipboardPlus },
] as const;

export function QuickActions({ includePlans = true }: { includePlans?: boolean }) {
  const actions = includePlans ? ACTIONS : ACTIONS.filter((action) => action.href !== "/plans?new=1");

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
