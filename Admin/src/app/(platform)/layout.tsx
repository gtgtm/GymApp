"use client";

import { useEffect, useState, type ReactNode } from "react";
import dynamic from "next/dynamic";
import { useRouter } from "next/navigation";
import { Menu } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Skeleton } from "@/components/ui/skeleton";
import { useAuth } from "@/hooks/use-auth";
import { PlatformSidebar } from "@/components/layout/platform-sidebar";
import { PlatformMobileNavDrawer } from "@/components/layout/platform-mobile-nav-drawer";

// Client-only, like NotificationBell: base-ui's Dialog module can't be
// evaluated during the static-export prerender.
const LogoutButton = dynamic(
  () => import("@/components/layout/logout-button").then((mod) => mod.LogoutButton),
  { ssr: false },
);

export default function PlatformLayout({ children }: { children: ReactNode }) {
  const { user, isLoading } = useAuth();
  const router = useRouter();
  const [isMobileNavOpen, setIsMobileNavOpen] = useState(false);

  useEffect(() => {
    if (!isLoading && !user) {
      router.replace("/login");
      return;
    }
    if (!isLoading && user && user.role.name !== "super_admin") {
      router.replace("/dashboard");
    }
  }, [isLoading, user, router]);

  if (isLoading || !user || user.role.name !== "super_admin") {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <Skeleton className="h-8 w-48" />
      </div>
    );
  }

  const initials = user.name
    .split(" ")
    .map((part) => part[0])
    .join("")
    .slice(0, 2)
    .toUpperCase();

  return (
    <div className="flex min-h-screen">
      <PlatformSidebar />
      <div className="flex min-w-0 flex-1 flex-col">
        <header className="flex h-16 items-center justify-between gap-2 border-b bg-background px-3 sm:px-6">
          <div className="flex min-w-0 flex-1 items-center gap-3">
            <Button
              variant="ghost"
              size="icon"
              className="shrink-0 md:hidden"
              onClick={() => setIsMobileNavOpen(true)}
              title="Open menu"
            >
              <Menu className="h-5 w-5" />
            </Button>
            <PlatformMobileNavDrawer
              open={isMobileNavOpen}
              onClose={() => setIsMobileNavOpen(false)}
            />
            <p className="hidden truncate text-sm text-muted-foreground lg:block">
              All Gyms
            </p>
          </div>
          <div className="flex shrink-0 items-center gap-2 sm:gap-3">
            <div className="hidden text-right sm:block">
              <p className="text-sm font-medium leading-none">{user.name}</p>
              <p className="text-xs text-muted-foreground">Platform Owner</p>
            </div>
            <Avatar>
              <AvatarFallback>{initials}</AvatarFallback>
            </Avatar>
            <LogoutButton />
          </div>
        </header>
        <main className="flex-1 overflow-y-auto overflow-x-hidden p-3 sm:p-4 md:p-6">
          {children}
        </main>
      </div>
    </div>
  );
}
