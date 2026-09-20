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
import { useUpdateSubscriptionPlan } from "@/hooks/use-subscription-plans";
import type { SubscriptionPlanTier } from "@/lib/api-types";
import { toast } from "sonner";
import { Pencil } from "lucide-react";

export function EditSubscriptionPlanDialog({ plan }: { plan: SubscriptionPlanTier }) {
  const [open, setOpen] = useState(false);
  const [name, setName] = useState(plan.name);
  const [description, setDescription] = useState(plan.description ?? "");
  const [memberLimit, setMemberLimit] = useState(
    plan.member_limit !== null ? String(plan.member_limit) : "",
  );
  const [price, setPrice] = useState(plan.price ?? "");
  const [status, setStatus] = useState(plan.status);
  const updatePlan = useUpdateSubscriptionPlan(plan.id);

  function handleOpenChange(nextOpen: boolean) {
    setOpen(nextOpen);
    if (nextOpen) {
      setName(plan.name);
      setDescription(plan.description ?? "");
      setMemberLimit(plan.member_limit !== null ? String(plan.member_limit) : "");
      setPrice(plan.price ?? "");
      setStatus(plan.status);
    }
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    try {
      await updatePlan.mutateAsync({
        name,
        description: description || undefined,
        member_limit: memberLimit ? Number(memberLimit) : null,
        price: price ? Number(price) : null,
        status,
      });
      toast.success(`${name} plan updated.`);
      setOpen(false);
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to update plan.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogTrigger
        render={
          <Button variant="outline" size="icon-sm" title="Edit">
            <Pencil className="h-3.5 w-3.5" />
          </Button>
        }
      />
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Edit Subscription Plan</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="edit_plan_name">Plan Name</Label>
            <Input
              id="edit_plan_name"
              required
              value={name}
              onChange={(e) => setName(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="edit_plan_description">Description</Label>
            <Input
              id="edit_plan_description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="edit_plan_member_limit">Member Limit (blank = unlimited)</Label>
            <Input
              id="edit_plan_member_limit"
              type="number"
              min={1}
              value={memberLimit}
              onChange={(e) => setMemberLimit(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="edit_plan_price">Price (₹ / month)</Label>
            <Input
              id="edit_plan_price"
              type="number"
              min={0}
              step="0.01"
              value={price}
              onChange={(e) => setPrice(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="edit_plan_status">Status</Label>
            <Select
              value={status}
              onValueChange={(value) => setStatus((value ?? "active") as "active" | "inactive")}
            >
              <SelectTrigger className="w-full" id="edit_plan_status">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="active">Active</SelectItem>
                <SelectItem value="inactive">Inactive</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <Button type="submit" className="w-full" disabled={updatePlan.isPending}>
            {updatePlan.isPending ? "Saving..." : "Save Changes"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
