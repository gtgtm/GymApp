"use client";

import { use } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { ArrowLeft, Users, UserCheck, IndianRupee, LogIn } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { StatCard } from "@/components/dashboard/stat-card";
import { useAuth } from "@/hooks/use-auth";
import { usePlatformGym } from "@/hooks/use-platform";
import { AssignSubscriptionDialog } from "@/components/platform/assign-subscription-dialog";
import { EditSubscriptionDialog } from "@/components/platform/edit-subscription-dialog";
import { EditGymDialog } from "@/components/platform/edit-gym-dialog";
import { ToggleGymStatusDialog } from "@/components/platform/toggle-gym-status-dialog";

const PAYMENT_STATUS_VARIANT = {
  active: "default",
  past_due: "destructive",
  cancelled: "secondary",
} as const;

export default function GymDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const gymId = Number(id);
  const router = useRouter();
  const { enterGym } = useAuth();
  const { data: gym, isLoading, isError, refetch } = usePlatformGym(gymId);

  function handleEnter() {
    if (!gym) return;
    enterGym({ id: gym.id, name: gym.name });
    router.push("/dashboard");
  }

  if (isLoading || !gym) {
    return (
      <div className="space-y-4">
        <Button
          variant="ghost"
          size="sm"
          className="gap-1.5"
          nativeButton={false}
          render={<Link href="/gyms" />}
        >
          <ArrowLeft className="h-3.5 w-3.5" />
          Back to gyms
        </Button>
        {isError ? (
          <Card>
            <CardContent className="flex flex-col items-center gap-3 py-10 text-center">
              <p className="text-sm text-muted-foreground">Failed to load gym.</p>
              <Button variant="outline" onClick={() => void refetch()}>
                Retry
              </Button>
            </CardContent>
          </Card>
        ) : (
          <Skeleton className="h-64 w-full" />
        )}
      </div>
    );
  }

  const subscription = gym.subscription;

  return (
    <div className="space-y-6">
      <div className="space-y-3">
        <Button
          variant="ghost"
          size="sm"
          className="gap-1.5"
          nativeButton={false}
          render={<Link href="/gyms" />}
        >
          <ArrowLeft className="h-3.5 w-3.5" />
          Back to gyms
        </Button>

        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div className="min-w-0">
            <h1 className="truncate text-xl font-semibold tracking-tight sm:text-2xl">
              {gym.name}
            </h1>
            <p className="text-sm text-muted-foreground">{gym.slug}</p>
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <Badge variant={gym.status === "active" ? "default" : "destructive"}>
              {gym.status}
            </Badge>
            <EditGymDialog gym={gym} />
            <ToggleGymStatusDialog gymId={gym.id} gymName={gym.name} status={gym.status} />
            <Button className="gap-1.5" onClick={handleEnter}>
              <LogIn className="h-4 w-4" />
              Enter as Admin
            </Button>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <StatCard label="Total Members" value={gym.members_count} icon={Users} />
        <StatCard
          label="Active Members"
          value={gym.active_members_count}
          icon={UserCheck}
          tone="success"
        />
        <StatCard
          label="Plan"
          value={
            subscription
              ? `${subscription.plan[0].toUpperCase()}${subscription.plan.slice(1)}`
              : "None"
          }
          icon={IndianRupee}
        />
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Contact</CardTitle>
          </CardHeader>
          <CardContent className="space-y-2 text-sm">
            <Field label="Email" value={gym.email} />
            <Field label="Phone" value={gym.phone} />
            <Field label="Address" value={gym.address} />
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0">
            <CardTitle>Subscription</CardTitle>
            {subscription ? (
              <EditSubscriptionDialog subscription={subscription} gymName={gym.name} />
            ) : (
              <AssignSubscriptionDialog gymId={gym.id} gymName={gym.name} />
            )}
          </CardHeader>
          <CardContent>
            {subscription ? (
              <div className="space-y-3 text-sm">
                <div className="flex items-center justify-between">
                  <span className="text-xs text-muted-foreground">Status</span>
                  <Badge variant={PAYMENT_STATUS_VARIANT[subscription.payment_status]}>
                    {subscription.payment_status.replace("_", " ")}
                  </Badge>
                </div>
                <Field
                  label="Member limit"
                  value={subscription.member_limit ? String(subscription.member_limit) : "Unlimited"}
                />
                <Field label="Start date" value={subscription.start_date} />
                <Field label="Expiry date" value={subscription.expiry_date} />
              </div>
            ) : (
              <p className="text-sm text-muted-foreground">No subscription assigned yet.</p>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

function Field({ label, value }: { label: string; value: string | null }) {
  return (
    <div>
      <p className="text-xs text-muted-foreground">{label}</p>
      <p className="font-medium">{value ?? "—"}</p>
    </div>
  );
}
