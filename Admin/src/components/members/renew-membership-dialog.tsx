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
import { usePlans } from "@/hooks/use-plans";
import { useRenewMembership } from "@/hooks/use-members";
import { toast } from "sonner";

const PAYMENT_METHODS = ["cash", "upi", "card", "bank_transfer", "online"] as const;

export function RenewMembershipDialog({ memberId }: { memberId: number }) {
  const [open, setOpen] = useState(false);
  const [planId, setPlanId] = useState<string>("");
  const [amountPaid, setAmountPaid] = useState<string>("");
  const [paymentMethod, setPaymentMethod] = useState<string>("cash");
  const { data: plans } = usePlans();
  const renewMembership = useRenewMembership(memberId);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!planId) {
      toast.error("Please select a plan.");
      return;
    }

    try {
      await renewMembership.mutateAsync({
        membership_plan_id: Number(planId),
        amount_paid: Number(amountPaid),
        payment_method: paymentMethod,
      });
      toast.success("Membership renewed successfully.");
      setOpen(false);
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Renewal failed.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger render={<Button>Renew Membership</Button>} />
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Renew Membership</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label>Plan</Label>
            <Select value={planId} onValueChange={(value) => setPlanId(value ?? "")}>
              <SelectTrigger>
                <SelectValue placeholder="Select a plan" />
              </SelectTrigger>
              <SelectContent>
                {plans?.map((plan) => (
                  <SelectItem key={plan.id} value={String(plan.id)}>
                    {plan.name} — ₹{plan.total_amount}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <Label htmlFor="amount_paid">Amount Paid</Label>
            <Input
              id="amount_paid"
              type="number"
              min="0"
              step="0.01"
              required
              value={amountPaid}
              onChange={(event) => setAmountPaid(event.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label>Payment Method</Label>
            <Select value={paymentMethod} onValueChange={(value) => setPaymentMethod(value ?? "cash")}>
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {PAYMENT_METHODS.map((method) => (
                  <SelectItem key={method} value={method}>
                    {method.replace("_", " ")}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <Button type="submit" className="w-full" disabled={renewMembership.isPending}>
            {renewMembership.isPending ? "Processing..." : "Confirm Renewal"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
