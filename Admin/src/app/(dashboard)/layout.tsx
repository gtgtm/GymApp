"use client";

import { useEffect, type ReactNode } from "react";
import { useRouter, usePathname } from "next/navigation";
import { useAuth } from "@/hooks/use-auth";
import { Sidebar } from "@/components/layout/sidebar";
import { Topbar } from "@/components/layout/topbar";
import { Skeleton } from "@/components/ui/skeleton";
import { canAccessRoute } from "@/lib/permissions";

export default function DashboardLayout({ children }: { children: ReactNode }) {
  const { user, isLoading, actingGym } = useAuth();
  const router = useRouter();
  const pathname = usePathname();
  const isSuperAdmin = user?.role.name === "super_admin";
  const needsGymSelection = isSuperAdmin && !actingGym;

  useEffect(() => {
    if (!isLoading && !user) {
      router.replace("/login");
    }
  }, [isLoading, user, router]);

  // super_admin has no gym of its own — every gym-scoped screen requires
  // having entered one first via the gym directory (see /gyms).
  useEffect(() => {
    if (needsGymSelection) {
      router.replace("/platform");
    }
  }, [needsGymSelection, router]);

  useEffect(() => {
    if (user && !needsGymSelection && !canAccessRoute(user.role.name, pathname)) {
      router.replace("/dashboard");
    }
  }, [user, needsGymSelection, pathname, router]);

  const isAuthorizedForRoute = user ? canAccessRoute(user.role.name, pathname) : false;

  if (isLoading || !user || needsGymSelection || !isAuthorizedForRoute) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <Skeleton className="h-8 w-48" />
      </div>
    );
  }

  return (
    <div className="flex min-h-screen">
      <Sidebar />
      <div className="flex min-w-0 flex-1 flex-col">
        <Topbar />
        <main className="flex-1 overflow-y-auto overflow-x-hidden p-3 sm:p-4 md:p-6">
          {children}
        </main>
      </div>
    </div>
  );
}
