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
import { useCreateSubscription } from "@/hooks/use-subscriptions";
import type { SubscriptionPlan } from "@/lib/api-types";
import { toast } from "sonner";

const PLANS: SubscriptionPlan[] = ["starter", "professional", "enterprise"];

function todayIsoDate(): string {
  return new Date().toISOString().slice(0, 10);
}

function oneYearFromTodayIsoDate(): string {
  const date = new Date();
  date.setFullYear(date.getFullYear() + 1);
  return date.toISOString().slice(0, 10);
}

export function AssignSubscriptionDialog({
  gymId,
  gymName,
}: {
  gymId: number;
  gymName: string;
}) {
  const [open, setOpen] = useState(false);
  const [plan, setPlan] = useState<SubscriptionPlan>("starter");
  const [startDate, setStartDate] = useState(todayIsoDate());
  const [expiryDate, setExpiryDate] = useState(oneYearFromTodayIsoDate());
  const createSubscription = useCreateSubscription();

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    try {
      await createSubscription.mutateAsync({
        gym_id: gymId,
        plan,
        start_date: startDate,
        expiry_date: expiryDate,
      });
      toast.success(`Subscription assigned to ${gymName}.`);
      setOpen(false);
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to assign subscription.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger render={<Button size="sm">Assign Subscription</Button>} />
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Assign Subscription — {gymName}</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="plan">Plan</Label>
            <Select
              value={plan}
              onValueChange={(value) => setPlan((value ?? "starter") as SubscriptionPlan)}
            >
              <SelectTrigger className="w-full" id="plan">
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
            <Label htmlFor="start_date">Start Date</Label>
            <Input
              id="start_date"
              type="date"
              required
              value={startDate}
              onChange={(e) => setStartDate(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="expiry_date">Expiry Date</Label>
            <Input
              id="expiry_date"
              type="date"
              required
              value={expiryDate}
              onChange={(e) => setExpiryDate(e.target.value)}
            />
          </div>
          <Button type="submit" className="w-full" disabled={createSubscription.isPending}>
            {createSubscription.isPending ? "Assigning..." : "Assign Subscription"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
