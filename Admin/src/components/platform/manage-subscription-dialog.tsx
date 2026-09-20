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
import { usePlatformGyms } from "@/hooks/use-platform";
import type { SubscriptionPlan } from "@/lib/api-types";
import { toast } from "sonner";
import { CreditCard } from "lucide-react";

const PLANS: SubscriptionPlan[] = ["starter", "professional", "enterprise"];

function todayIsoDate(): string {
  return new Date().toISOString().slice(0, 10);
}

function oneYearFromTodayIsoDate(): string {
  const date = new Date();
  date.setFullYear(date.getFullYear() + 1);
  return date.toISOString().slice(0, 10);
}

export function ManageSubscriptionDialog() {
  const [open, setOpen] = useState(false);
  const [gymId, setGymId] = useState<string>("");
  const [plan, setPlan] = useState<SubscriptionPlan>("starter");
  const [startDate, setStartDate] = useState(todayIsoDate());
  const [expiryDate, setExpiryDate] = useState(oneYearFromTodayIsoDate());
  const { data: gyms } = usePlatformGyms();
  const createSubscription = useCreateSubscription();

  const unsubscribedGyms = gyms?.filter((gym) => !gym.subscription) ?? [];

  function handleOpenChange(nextOpen: boolean) {
    setOpen(nextOpen);
    if (nextOpen) {
      setGymId("");
      setPlan("starter");
      setStartDate(todayIsoDate());
      setExpiryDate(oneYearFromTodayIsoDate());
    }
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!gymId) return;

    try {
      await createSubscription.mutateAsync({
        gym_id: Number(gymId),
        plan,
        start_date: startDate,
        expiry_date: expiryDate,
      });
      const gymName = unsubscribedGyms.find((g) => g.id === Number(gymId))?.name ?? "the gym";
      toast.success(`Subscription assigned to ${gymName}.`);
      setOpen(false);
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to assign subscription.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogTrigger
        render={
          <Button className="gap-1.5">
            <CreditCard className="h-4 w-4" />
            Manage Subscription
          </Button>
        }
      />
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Assign Subscription</DialogTitle>
        </DialogHeader>
        {unsubscribedGyms.length === 0 ? (
          <p className="text-sm text-muted-foreground">
            Every gym already has a subscription. Edit one from the table below.
          </p>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="manage_gym">Gym</Label>
              <Select value={gymId} onValueChange={(value) => setGymId(value ?? "")}>
                <SelectTrigger className="w-full" id="manage_gym">
                  <SelectValue placeholder="Select a gym" />
                </SelectTrigger>
                <SelectContent>
                  {unsubscribedGyms.map((gym) => (
                    <SelectItem key={gym.id} value={String(gym.id)}>
                      {gym.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label htmlFor="manage_plan">Plan</Label>
              <Select
                value={plan}
                onValueChange={(value) => setPlan((value ?? "starter") as SubscriptionPlan)}
              >
                <SelectTrigger className="w-full" id="manage_plan">
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
              <Label htmlFor="manage_start_date">Start Date</Label>
              <Input
                id="manage_start_date"
                type="date"
                required
                value={startDate}
                onChange={(e) => setStartDate(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="manage_expiry_date">Expiry Date</Label>
              <Input
                id="manage_expiry_date"
                type="date"
                required
                value={expiryDate}
                onChange={(e) => setExpiryDate(e.target.value)}
              />
            </div>
            <Button
              type="submit"
              className="w-full"
              disabled={!gymId || createSubscription.isPending}
            >
              {createSubscription.isPending ? "Assigning..." : "Assign Subscription"}
            </Button>
          </form>
        )}
      </DialogContent>
    </Dialog>
  );
}
