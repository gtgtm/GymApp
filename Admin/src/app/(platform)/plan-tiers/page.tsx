"use client";

import { Layers } from "lucide-react";
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
import { useSubscriptionPlans } from "@/hooks/use-subscription-plans";
import { CreateSubscriptionPlanDialog } from "@/components/platform/create-subscription-plan-dialog";
import { EditSubscriptionPlanDialog } from "@/components/platform/edit-subscription-plan-dialog";
import { DeleteSubscriptionPlanDialog } from "@/components/platform/delete-subscription-plan-dialog";

export default function PlanTiersPage() {
  const { data: plans, isLoading, isError, refetch } = useSubscriptionPlans();

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-8 w-40" />
        <Skeleton className="h-96 w-full" />
      </div>
    );
  }

  if (isError || !plans) {
    return (
      <Card>
        <CardContent className="flex flex-col items-center gap-3 py-10 text-center">
          <p className="text-sm text-muted-foreground">Failed to load plans.</p>
          <Button variant="outline" onClick={() => void refetch()}>
            Retry
          </Button>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">Plans</h1>
          <p className="text-sm text-muted-foreground">
            Billing tiers gyms can be subscribed to.
          </p>
        </div>
        <CreateSubscriptionPlanDialog />
      </div>

      <Card>
        {plans.length === 0 ? (
          <CardContent className="flex flex-col items-center gap-2 py-10 text-center">
            <Layers className="h-8 w-8 text-muted-foreground" />
            <p className="text-sm text-muted-foreground">No plans yet.</p>
          </CardContent>
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Plan</TableHead>
                <TableHead>Member Limit</TableHead>
                <TableHead>Price</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {plans.map((plan) => (
                <TableRow key={plan.id}>
                  <TableCell className="font-medium">
                    <p>{plan.name}</p>
                    {plan.description && (
                      <p className="text-xs text-muted-foreground">{plan.description}</p>
                    )}
                  </TableCell>
                  <TableCell>{plan.member_limit ?? "Unlimited"}</TableCell>
                  <TableCell>{plan.price ? `₹${plan.price}/mo` : "—"}</TableCell>
                  <TableCell>
                    <Badge variant={plan.status === "active" ? "default" : "secondary"}>
                      {plan.status}
                    </Badge>
                  </TableCell>
                  <TableCell className="text-right">
                    <div className="flex justify-end gap-2">
                      <EditSubscriptionPlanDialog plan={plan} />
                      <DeleteSubscriptionPlanDialog planId={plan.id} planName={plan.name} />
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
