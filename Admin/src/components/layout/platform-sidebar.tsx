"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { LayoutDashboard, Building2, CreditCard, Layers } from "lucide-react";
import { cn } from "@/lib/utils";

const PLATFORM_NAV_ITEMS = [
  { href: "/platform", label: "Dashboard", icon: LayoutDashboard },
  { href: "/gyms", label: "Gyms", icon: Building2 },
  { href: "/subscriptions", label: "Subscriptions", icon: CreditCard },
  { href: "/plan-tiers", label: "Plans", icon: Layers },
];

interface PlatformSidebarNavProps {
  onNavigate?: () => void;
}

export function PlatformSidebarNav({ onNavigate }: PlatformSidebarNavProps) {
  const pathname = usePathname();

  return (
    <>
      <div className="flex h-16 shrink-0 items-center gap-2 border-b px-6">
        <span className="text-lg font-semibold tracking-tight">GymBrain</span>
        <span className="rounded-full bg-primary/10 px-2 py-0.5 text-[11px] font-medium text-primary">
          Platform
        </span>
      </div>
      <nav className="flex flex-1 flex-col gap-1 overflow-y-auto p-3">
        {PLATFORM_NAV_ITEMS.map(({ href, label, icon: Icon }) => {
          const isActive = pathname.startsWith(href);
          return (
            <Link
              key={href}
              href={href}
              onClick={onNavigate}
              className={cn(
                "flex items-center gap-3 rounded-md px-3 py-2 text-[16px] font-medium transition-colors",
                isActive
                  ? "bg-primary text-primary-foreground"
                  : "text-muted-foreground hover:bg-muted hover:text-foreground",
              )}
            >
              <Icon className="h-4 w-4 shrink-0" />
              {label}
            </Link>
          );
        })}
      </nav>
    </>
  );
}

export function PlatformSidebar() {
  return (
    <aside className="hidden w-64 shrink-0 border-r bg-background md:flex md:flex-col">
      <PlatformSidebarNav />
    </aside>
  );
}
