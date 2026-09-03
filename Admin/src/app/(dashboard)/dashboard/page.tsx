"use client";

import { useAuth } from "@/hooks/use-auth";
import { AdminDashboard } from "@/components/dashboard/admin-dashboard";
import { ReceptionistDashboard } from "@/components/dashboard/receptionist-dashboard";
import { TrainerDashboard } from "@/components/dashboard/trainer-dashboard";
import { Skeleton } from "@/components/ui/skeleton";

export default function DashboardPage() {
  const { user } = useAuth();

  if (!user) {
    return <Skeleton className="h-28 w-full" />;
  }

  switch (user.role.name) {
    case "receptionist":
      return <ReceptionistDashboard />;
    case "trainer":
      return <TrainerDashboard />;
    default:
      return <AdminDashboard />;
  }
}
