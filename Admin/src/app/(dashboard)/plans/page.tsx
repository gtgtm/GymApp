"use client";

import { useSearchParams } from "next/navigation";
import { usePlans } from "@/hooks/use-plans";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { CreatePlanDialog } from "@/components/plans/create-plan-dialog";

export default function PlansPage() {
  const searchParams = useSearchParams();
  const { data: plans, isLoading } = usePlans();

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold tracking-tight">Membership Plans</h1>
        <CreatePlanDialog defaultOpen={searchParams.get("new") === "1"} />
      </div>

      {isLoading ? (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {Array.from({ length: 3 }).map((_, index) => (
            <Skeleton key={index} className="h-48 w-full" />
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {plans?.map((plan) => (
            <Card key={plan.id}>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle>{plan.name}</CardTitle>
                  <Badge variant={plan.status === "active" ? "default" : "secondary"}>
                    {plan.status}
                  </Badge>
                </div>
              </CardHeader>
              <CardContent className="space-y-2">
                <p className="text-3xl font-bold">₹{plan.total_amount}</p>
                <p className="text-sm text-muted-foreground">{plan.duration_days} days</p>
                {plan.description && (
                  <p className="text-sm text-muted-foreground">{plan.description}</p>
                )}
                {plan.benefits && plan.benefits.length > 0 && (
                  <ul className="list-inside list-disc text-sm">
                    {plan.benefits.map((benefit) => (
                      <li key={benefit}>{benefit}</li>
                    ))}
                  </ul>
                )}
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
