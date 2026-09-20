"use client";

import Link from "next/link";
import {
  Building2,
  Users,
  AlertTriangle,
  IndianRupee,
  ArrowRight,
} from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { StatCard } from "@/components/dashboard/stat-card";
import { usePlatformGyms } from "@/hooks/use-platform";
import type { PlatformGymSummary } from "@/lib/api-types";

const PLAN_LABELS: Record<string, string> = {
  starter: "Starter",
  professional: "Professional",
  enterprise: "Enterprise",
};

const PLAN_ORDER = ["starter", "professional", "enterprise"] as const;

const DAYS_UNTIL_ATTENTION = 14;

function daysUntil(dateString: string): number {
  const diffMs = new Date(dateString).getTime() - Date.now();
  return Math.ceil(diffMs / (1000 * 60 * 60 * 24));
}

function needsAttention(gym: PlatformGymSummary): boolean {
  if (!gym.subscription) return true;
  if (gym.subscription.payment_status !== "active") return true;
  return daysUntil(gym.subscription.expiry_date) <= DAYS_UNTIL_ATTENTION;
}

export default function PlatformDashboardPage() {
  const { data: gyms, isLoading, isError, refetch } = usePlatformGyms();

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {Array.from({ length: 4 }).map((_, index) => (
            <Skeleton key={index} className="h-28 w-full" />
          ))}
        </div>
        <Skeleton className="h-64 w-full" />
      </div>
    );
  }

  if (isError || !gyms) {
    return (
      <Card>
        <CardContent className="flex flex-col items-center gap-3 py-10 text-center">
          <p className="text-sm text-muted-foreground">Failed to load platform data.</p>
          <Button variant="outline" onClick={() => void refetch()}>
            Retry
          </Button>
        </CardContent>
      </Card>
    );
  }

  const totalMembers = gyms.reduce((sum, gym) => sum + gym.members_count, 0);
  const activeGyms = gyms.filter((gym) => gym.status === "active").length;
  const attentionGyms = gyms.filter(needsAttention);

  const planCounts = PLAN_ORDER.reduce<Record<string, number>>((acc, plan) => {
    acc[plan] = gyms.filter((gym) => gym.subscription?.plan === plan).length;
    return acc;
  }, {});
  const unsubscribedCount = gyms.filter((gym) => !gym.subscription).length;
  const maxPlanCount = Math.max(1, ...Object.values(planCounts), unsubscribedCount);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">Dashboard</h1>
        <p className="text-sm text-muted-foreground">
          Platform-wide health across every gym on GymBrain.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard label="Total Gyms" value={gyms.length} icon={Building2} />
        <StatCard label="Active Gyms" value={activeGyms} icon={Building2} tone="success" />
        <StatCard label="Total Members" value={totalMembers.toLocaleString("en-IN")} icon={Users} />
        <StatCard
          label="Needs Attention"
          value={attentionGyms.length}
          icon={AlertTriangle}
          tone={attentionGyms.length > 0 ? "danger" : "default"}
        />
      </div>

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
        <Card className="lg:col-span-2">
          <CardHeader className="flex flex-row items-center justify-between space-y-0">
            <CardTitle>Needs Attention</CardTitle>
            <Button
              variant="ghost"
              size="sm"
              className="gap-1 text-muted-foreground"
              nativeButton={false}
              render={<Link href="/gyms" />}
            >
              View all gyms
              <ArrowRight className="h-3.5 w-3.5" />
            </Button>
          </CardHeader>
          <CardContent>
            {attentionGyms.length === 0 ? (
              <p className="py-6 text-center text-sm text-muted-foreground">
                All gyms are current on their subscriptions.
              </p>
            ) : (
              <div className="space-y-1">
                {attentionGyms.map((gym) => (
                  <Link
                    key={gym.id}
                    href={`/gyms/${gym.id}`}
                    className="flex items-center justify-between gap-3 rounded-md px-2 py-2.5 text-sm transition-colors hover:bg-muted"
                  >
                    <div className="min-w-0">
                      <p className="truncate font-medium">{gym.name}</p>
                      <p className="text-xs text-muted-foreground">
                        {gym.subscription
                          ? `Expires ${gym.subscription.expiry_date}`
                          : "No subscription assigned"}
                      </p>
                    </div>
                    <Badge
                      variant={
                        gym.subscription?.payment_status === "past_due"
                          ? "destructive"
                          : "secondary"
                      }
                    >
                      {gym.subscription?.payment_status.replace("_", " ") ?? "unassigned"}
                    </Badge>
                  </Link>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Plan Distribution</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {PLAN_ORDER.map((plan) => (
              <PlanBar
                key={plan}
                label={PLAN_LABELS[plan]}
                count={planCounts[plan]}
                max={maxPlanCount}
              />
            ))}
            <PlanBar label="No subscription" count={unsubscribedCount} max={maxPlanCount} muted />
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

function PlanBar({
  label,
  count,
  max,
  muted = false,
}: {
  label: string;
  count: number;
  max: number;
  muted?: boolean;
}) {
  const widthPercent = max === 0 ? 0 : (count / max) * 100;

  return (
    <div className="space-y-1.5">
      <div className="flex items-center justify-between text-sm">
        <span className={muted ? "text-muted-foreground" : "font-medium"}>{label}</span>
        <span className="inline-flex items-center gap-1 text-muted-foreground">
          <IndianRupee className="h-3 w-3" />
          {count}
        </span>
      </div>
      <div className="h-1.5 overflow-hidden rounded-full bg-muted">
        <div
          className={muted ? "h-full bg-muted-foreground/40" : "h-full bg-primary"}
          style={{ width: `${widthPercent}%` }}
        />
      </div>
    </div>
  );
}
