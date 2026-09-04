"use client";

import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { useMySubscription } from "@/hooks/use-subscription";

const PLAN_LABELS: Record<string, string> = {
  starter: "Starter",
  professional: "Professional",
  enterprise: "Enterprise",
};

const STATUS_STYLES: Record<string, string> = {
  active: "bg-emerald-100 text-emerald-700",
  past_due: "bg-amber-100 text-amber-700",
  cancelled: "bg-red-100 text-red-700",
};

export function SubscriptionStatus() {
  const { data: subscription, isLoading } = useMySubscription();
  const [now] = useState(() => Date.now());

  if (isLoading || !subscription) {
    return null;
  }

  const isExpiringSoon =
    new Date(subscription.expiry_date).getTime() - now < 30 * 24 * 60 * 60 * 1000;

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle className="text-sm text-muted-foreground">Subscription</CardTitle>
        <Badge className={STATUS_STYLES[subscription.payment_status]}>
          {subscription.payment_status.replace("_", " ")}
        </Badge>
      </CardHeader>
      <CardContent className="space-y-1">
        <p className="text-lg font-semibold">{PLAN_LABELS[subscription.plan]}</p>
        <p className="text-sm text-muted-foreground">
          {subscription.member_limit
            ? `Up to ${subscription.member_limit.toLocaleString("en-IN")} members`
            : "Unlimited members"}
        </p>
        <p className={`text-xs ${isExpiringSoon ? "text-amber-600" : "text-muted-foreground"}`}>
          Expires {new Date(subscription.expiry_date).toLocaleDateString()}
        </p>
      </CardContent>
    </Card>
  );
}
