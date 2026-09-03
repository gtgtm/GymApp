"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  LayoutDashboard,
  Users,
  CreditCard,
  CalendarCheck,
  ClipboardList,
  Dumbbell,
  UserSearch,
  Hourglass,
  Receipt,
  Wrench,
  BarChart3,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useAuth } from "@/hooks/use-auth";
import { canAccessNav, type NavKey } from "@/lib/permissions";

const NAV_ITEMS: { href: string; label: string; icon: typeof LayoutDashboard; key: NavKey }[] = [
  { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard, key: "dashboard" },
  { href: "/members", label: "Members", icon: Users, key: "members" },
  { href: "/enquiries", label: "Enquiries", icon: UserSearch, key: "enquiries" },
  { href: "/trials", label: "Trials", icon: Hourglass, key: "trials" },
  { href: "/trainers", label: "Trainers", icon: Dumbbell, key: "trainers" },
  { href: "/plans", label: "Membership Plans", icon: ClipboardList, key: "plans" },
  { href: "/payments", label: "Payments", icon: CreditCard, key: "payments" },
  { href: "/attendance", label: "Attendance", icon: CalendarCheck, key: "attendance" },
  { href: "/expenses", label: "Expenses", icon: Receipt, key: "expenses" },
  { href: "/equipment", label: "Equipment", icon: Wrench, key: "equipment" },
  { href: "/reports", label: "Reports", icon: BarChart3, key: "reports" },
];

export function Sidebar() {
  const pathname = usePathname();
  const { user } = useAuth();
  const visibleItems = NAV_ITEMS.filter((item) => canAccessNav(user?.role.name, item.key));

  return (
    <aside className="hidden w-64 shrink-0 border-r bg-background md:flex md:flex-col">
      <div className="flex h-16 items-center border-b px-6">
        <span className="text-lg font-semibold tracking-tight">GymApp</span>
      </div>
      <nav className="flex flex-1 flex-col gap-1 p-3">
        {visibleItems.map(({ href, label, icon: Icon }) => {
          const isActive = pathname.startsWith(href);
          return (
            <Link
              key={href}
              href={href}
              className={cn(
                "flex items-center gap-3 rounded-md px-3 py-2 text-sm font-medium transition-colors",
                isActive
                  ? "bg-primary text-primary-foreground"
                  : "text-muted-foreground hover:bg-muted hover:text-foreground",
              )}
            >
              <Icon className="h-4 w-4" />
              {label}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
