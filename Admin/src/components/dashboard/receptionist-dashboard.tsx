"use client";

import { Users, UserCheck, CalendarDays, UserPlus } from "lucide-react";
import { useDashboard } from "@/hooks/use-dashboard";
import { StatCard } from "@/components/dashboard/stat-card";
import { QuickActions } from "@/components/dashboard/quick-actions";
import { ExpiryBuckets } from "@/components/dashboard/expiry-buckets";
import { Skeleton } from "@/components/ui/skeleton";

export function ReceptionistDashboard() {
  const { data, isLoading } = useDashboard();

  if (isLoading || !data) {
    return (
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {Array.from({ length: 6 }).map((_, index) => (
          <Skeleton key={index} className="h-28 w-full" />
        ))}
      </div>
    );
  }

  const { summary, expiring } = data;

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-semibold tracking-tight">Front Desk Dashboard</h1>

      <QuickActions includePlans={false} />

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard label="Total Members" value={summary.total_members} icon={Users} />
        <StatCard
          label="Active Members"
          value={summary.active_members}
          icon={UserCheck}
          tone="success"
        />
        <StatCard
          label="Expiring Soon"
          value={summary.expiring_soon}
          icon={CalendarDays}
          tone="warning"
        />
        <StatCard label="Today's Attendance" value={summary.todays_attendance} icon={UserCheck} />
        <StatCard label="Today's New Members" value={summary.todays_new_members} icon={UserPlus} />
        <StatCard
          label="Expired Memberships"
          value={summary.expired_memberships}
          icon={CalendarDays}
          tone="danger"
        />
      </div>

      <ExpiryBuckets expiring={expiring} />
    </div>
  );
}
