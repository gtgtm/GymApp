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
import { useCreateSubscriptionPlan } from "@/hooks/use-subscription-plans";
import { toast } from "sonner";
import { Plus } from "lucide-react";

export function CreateSubscriptionPlanDialog() {
  const [open, setOpen] = useState(false);
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [memberLimit, setMemberLimit] = useState("");
  const [price, setPrice] = useState("");
  const createPlan = useCreateSubscriptionPlan();

  function reset() {
    setName("");
    setDescription("");
    setMemberLimit("");
    setPrice("");
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    try {
      await createPlan.mutateAsync({
        name,
        description: description || undefined,
        member_limit: memberLimit ? Number(memberLimit) : null,
        price: price ? Number(price) : null,
      });
      toast.success(`${name} plan created.`);
      setOpen(false);
      reset();
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to create plan.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger
        render={
          <Button className="gap-1.5">
            <Plus className="h-4 w-4" />
            Add Plan
          </Button>
        }
      />
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Add Subscription Plan</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="plan_name">Plan Name</Label>
            <Input id="plan_name" required value={name} onChange={(e) => setName(e.target.value)} />
          </div>
          <div className="space-y-2">
            <Label htmlFor="plan_description">Description (optional)</Label>
            <Input
              id="plan_description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="plan_member_limit">Member Limit (blank = unlimited)</Label>
            <Input
              id="plan_member_limit"
              type="number"
              min={1}
              value={memberLimit}
              onChange={(e) => setMemberLimit(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="plan_price">Price (₹ / month, optional)</Label>
            <Input
              id="plan_price"
              type="number"
              min={0}
              step="0.01"
              value={price}
              onChange={(e) => setPrice(e.target.value)}
            />
          </div>
          <Button type="submit" className="w-full" disabled={createPlan.isPending}>
            {createPlan.isPending ? "Creating..." : "Create Plan"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
