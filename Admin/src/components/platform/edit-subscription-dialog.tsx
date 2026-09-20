"use client";

import { useState, type FormEvent } from "react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useUpdateSubscription } from "@/hooks/use-subscriptions";
import type { Subscription, SubscriptionPlan } from "@/lib/api-types";
import { toast } from "sonner";
import { Pencil } from "lucide-react";

const PLANS: SubscriptionPlan[] = ["starter", "professional", "enterprise"];
const PAYMENT_STATUSES = ["active", "past_due", "cancelled"] as const;

export function EditSubscriptionDialog({
  subscription,
  gymName,
  iconOnly = false,
}: {
  subscription: Subscription;
  gymName: string;
  iconOnly?: boolean;
}) {
  const [open, setOpen] = useState(false);
  const [plan, setPlan] = useState<SubscriptionPlan>(subscription.plan);
  const [startDate, setStartDate] = useState(subscription.start_date.slice(0, 10));
  const [expiryDate, setExpiryDate] = useState(subscription.expiry_date.slice(0, 10));
  const [paymentStatus, setPaymentStatus] = useState(subscription.payment_status);
  const updateSubscription = useUpdateSubscription(subscription.id);

  function handleOpenChange(nextOpen: boolean) {
    setOpen(nextOpen);
    if (nextOpen) {
      setPlan(subscription.plan);
      setStartDate(subscription.start_date.slice(0, 10));
      setExpiryDate(subscription.expiry_date.slice(0, 10));
      setPaymentStatus(subscription.payment_status);
    }
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    try {
      await updateSubscription.mutateAsync({
        plan,
        start_date: startDate,
        expiry_date: expiryDate,
        payment_status: paymentStatus,
      });
      toast.success(`Subscription updated for ${gymName}.`);
      setOpen(false);
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to update subscription.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogTrigger
        render={
          iconOnly ? (
            <Button variant="outline" size="icon-sm" title="Edit Subscription">
              <Pencil className="h-3.5 w-3.5" />
            </Button>
          ) : (
            <Button variant="outline" size="sm" className="gap-1.5">
              <Pencil className="h-3.5 w-3.5" />
              Edit
            </Button>
          )
        }
      />
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Edit Subscription — {gymName}</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="edit_plan">Plan</Label>
            <Select
              value={plan}
              onValueChange={(value) => setPlan((value ?? "starter") as SubscriptionPlan)}
            >
              <SelectTrigger className="w-full" id="edit_plan">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {PLANS.map((p) => (
                  <SelectItem key={p} value={p}>
                    {p.charAt(0).toUpperCase() + p.slice(1)}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <Label htmlFor="edit_payment_status">Payment Status</Label>
            <Select
              value={paymentStatus}
              onValueChange={(value) =>
                setPaymentStatus((value ?? "active") as (typeof PAYMENT_STATUSES)[number])
              }
            >
              <SelectTrigger className="w-full" id="edit_payment_status">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {PAYMENT_STATUSES.map((s) => (
                  <SelectItem key={s} value={s}>
                    {s.replace("_", " ")}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <Label htmlFor="edit_start_date">Start Date</Label>
            <Input
              id="edit_start_date"
              type="date"
              required
              value={startDate}
              onChange={(e) => setStartDate(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="edit_expiry_date">Expiry Date</Label>
            <Input
              id="edit_expiry_date"
              type="date"
              required
              value={expiryDate}
              onChange={(e) => setExpiryDate(e.target.value)}
            />
          </div>
          <Button type="submit" className="w-full" disabled={updateSubscription.isPending}>
            {updateSubscription.isPending ? "Saving..." : "Save Changes"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
