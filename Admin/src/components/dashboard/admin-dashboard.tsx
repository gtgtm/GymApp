"use client";

import {
  Users,
  UserCheck,
  CalendarDays,
  IndianRupee,
  Wallet,
  UserPlus,
  TrendingUp,
  UserSearch,
  Dumbbell,
} from "lucide-react";
import { useDashboard } from "@/hooks/use-dashboard";
import { StatCard } from "@/components/dashboard/stat-card";
import { QuickActions } from "@/components/dashboard/quick-actions";
import { ExpiryBuckets } from "@/components/dashboard/expiry-buckets";
import { Skeleton } from "@/components/ui/skeleton";

export function AdminDashboard() {
  const { data, isLoading } = useDashboard();

  if (isLoading || !data) {
    return (
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {Array.from({ length: 8 }).map((_, index) => (
          <Skeleton key={index} className="h-28 w-full" />
        ))}
      </div>
    );
  }

  const { summary, expiring } = data;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold tracking-tight">Dashboard</h1>
      </div>

      <QuickActions />

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard label="Total Members" value={summary.total_members} icon={Users} />
        <StatCard
          label="Active Members"
          value={summary.active_members}
          icon={UserCheck}
          tone="success"
        />
        <StatCard
          label="Expired Memberships"
          value={summary.expired_memberships}
          icon={CalendarDays}
          tone="danger"
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
          label="Today's Revenue"
          value={`₹${summary.todays_revenue.toLocaleString("en-IN")}`}
          icon={IndianRupee}
          tone="success"
        />
        <StatCard
          label="Monthly Revenue"
          value={`₹${summary.monthly_revenue.toLocaleString("en-IN")}`}
          icon={IndianRupee}
          tone="success"
        />
        <StatCard
          label="Pending Payments"
          value={`₹${summary.pending_payments.toLocaleString("en-IN")}`}
          icon={Wallet}
          tone="warning"
        />
        <StatCard
          label="Net Profit (This Month)"
          value={`₹${summary.monthly_net_profit.toLocaleString("en-IN")}`}
          icon={TrendingUp}
          tone={summary.monthly_net_profit >= 0 ? "success" : "danger"}
        />
        <StatCard label="New Enquiries" value={summary.new_enquiries} icon={UserSearch} />
        <StatCard label="Active Trainers" value={summary.active_trainers} icon={Dumbbell} />
      </div>

      <ExpiryBuckets expiring={expiring} />
    </div>
  );
}
