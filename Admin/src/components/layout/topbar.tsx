"use client";

import { useState } from "react";
import dynamic from "next/dynamic";
import { LogOut, Menu } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { useAuth } from "@/hooks/use-auth";
import { GlobalSearchBar } from "@/components/layout/global-search-bar";
import { MobileNavDrawer } from "@/components/layout/mobile-nav-drawer";

const NotificationBell = dynamic(
  () => import("@/components/layout/notification-bell").then((mod) => mod.NotificationBell),
  { ssr: false },
);

export function Topbar() {
  const { user, logout } = useAuth();
  const [isMobileNavOpen, setIsMobileNavOpen] = useState(false);

  const initials = user?.name
    ?.split(" ")
    .map((part) => part[0])
    .join("")
    .slice(0, 2)
    .toUpperCase();

  return (
    <header className="flex h-16 items-center justify-between gap-2 border-b bg-background px-3 sm:px-6">
      <div className="flex min-w-0 flex-1 items-center gap-3 sm:gap-6">
        <Button
          variant="ghost"
          size="icon"
          className="shrink-0 md:hidden"
          onClick={() => setIsMobileNavOpen(true)}
          title="Open menu"
        >
          <Menu className="h-5 w-5" />
        </Button>
        <MobileNavDrawer open={isMobileNavOpen} onClose={() => setIsMobileNavOpen(false)} />
        <p className="hidden truncate text-sm text-muted-foreground lg:block">{user?.gym.name}</p>
        <div className="hidden min-w-0 flex-1 sm:block sm:max-w-xs md:max-w-sm">
          <GlobalSearchBar />
        </div>
      </div>
      <div className="flex shrink-0 items-center gap-2 sm:gap-3">
        <NotificationBell />
        <div className="hidden text-right sm:block">
          <p className="text-sm font-medium leading-none">{user?.name}</p>
          <p className="text-xs text-muted-foreground capitalize">{user?.role.label}</p>
        </div>
        <Avatar>
          <AvatarFallback>{initials}</AvatarFallback>
        </Avatar>
        <Button variant="ghost" size="icon" onClick={() => void logout()} title="Log out">
          <LogOut className="h-4 w-4" />
        </Button>
      </div>
    </header>
  );
}
