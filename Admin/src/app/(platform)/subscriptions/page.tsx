"use client";

import Link from "next/link";
import { IndianRupee, AlertTriangle, XCircle, CheckCircle2 } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Skeleton } from "@/components/ui/skeleton";
import { StatCard } from "@/components/dashboard/stat-card";
import { useSubscriptions } from "@/hooks/use-subscriptions";
import { EditSubscriptionDialog } from "@/components/platform/edit-subscription-dialog";
import { ManageSubscriptionDialog } from "@/components/platform/manage-subscription-dialog";

const STATUS_VARIANT = {
  active: "default",
  past_due: "destructive",
  cancelled: "secondary",
} as const;

export default function SubscriptionsPage() {
  const { data: subscriptions, isLoading, isError, refetch } = useSubscriptions();

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
          {Array.from({ length: 3 }).map((_, index) => (
            <Skeleton key={index} className="h-28 w-full" />
          ))}
        </div>
        <Skeleton className="h-96 w-full" />
      </div>
    );
  }

  if (isError || !subscriptions) {
    return (
      <Card>
        <CardContent className="flex flex-col items-center gap-3 py-10 text-center">
          <p className="text-sm text-muted-foreground">Failed to load subscriptions.</p>
          <Button variant="outline" onClick={() => void refetch()}>
            Retry
          </Button>
        </CardContent>
      </Card>
    );
  }

  const activeCount = subscriptions.filter((s) => s.payment_status === "active").length;
  const pastDueCount = subscriptions.filter((s) => s.payment_status === "past_due").length;
  const cancelledCount = subscriptions.filter((s) => s.payment_status === "cancelled").length;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">Subscriptions</h1>
          <p className="text-sm text-muted-foreground">
            Billing status for every gym on the platform.
          </p>
        </div>
        <ManageSubscriptionDialog />
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <StatCard label="Active" value={activeCount} icon={CheckCircle2} tone="success" />
        <StatCard
          label="Past Due"
          value={pastDueCount}
          icon={AlertTriangle}
          tone={pastDueCount > 0 ? "danger" : "default"}
        />
        <StatCard label="Cancelled" value={cancelledCount} icon={XCircle} />
      </div>

      <Card>
        {subscriptions.length === 0 ? (
          <CardContent className="flex flex-col items-center gap-2 py-10 text-center">
            <IndianRupee className="h-8 w-8 text-muted-foreground" />
            <p className="text-sm text-muted-foreground">No subscriptions yet.</p>
          </CardContent>
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Gym</TableHead>
                <TableHead>Plan</TableHead>
                <TableHead>Member Limit</TableHead>
                <TableHead>Start Date</TableHead>
                <TableHead>Expiry Date</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {subscriptions.map((subscription) => (
                <TableRow key={subscription.id}>
                  <TableCell className="font-medium">
                    {subscription.gym ? (
                      <Link href={`/gyms/view?id=${subscription.gym.id}`} className="hover:underline">
                        {subscription.gym.name}
                      </Link>
                    ) : (
                      "—"
                    )}
                  </TableCell>
                  <TableCell className="capitalize">{subscription.plan}</TableCell>
                  <TableCell>{subscription.member_limit ?? "Unlimited"}</TableCell>
                  <TableCell>{subscription.start_date}</TableCell>
                  <TableCell>{subscription.expiry_date}</TableCell>
                  <TableCell>
                    <Badge variant={STATUS_VARIANT[subscription.payment_status]}>
                      {subscription.payment_status.replace("_", " ")}
                    </Badge>
                  </TableCell>
                  <TableCell className="text-right">
                    <div className="flex justify-end">
                      <EditSubscriptionDialog
                        subscription={subscription}
                        gymName={subscription.gym?.name ?? "this gym"}
                        iconOnly
                      />
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </Card>
    </div>
  );
}
