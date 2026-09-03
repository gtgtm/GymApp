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
import { useMembers } from "@/hooks/use-members";
import { useCreatePayment } from "@/hooks/use-payments";
import { toast } from "sonner";

const PAYMENT_METHODS = ["cash", "upi", "card", "bank_transfer", "online"] as const;

export function CreatePaymentDialog({ defaultOpen = false }: { defaultOpen?: boolean }) {
  const [open, setOpen] = useState(defaultOpen);
  const [memberId, setMemberId] = useState("");
  const [amount, setAmount] = useState("");
  const [method, setMethod] = useState("cash");
  const { data: membersResponse } = useMembers();
  const createPayment = useCreatePayment();

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!memberId) {
      toast.error("Please select a member.");
      return;
    }

    try {
      await createPayment.mutateAsync({
        member_id: Number(memberId),
        amount: Number(amount),
        method,
      });
      toast.success("Payment recorded and receipt generated.");
      setOpen(false);
      setAmount("");
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to record payment.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger render={<Button>Collect Payment</Button>} />
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Collect Payment</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label>Member</Label>
            <Select value={memberId} onValueChange={(value) => setMemberId(value ?? "")}>
              <SelectTrigger>
                <SelectValue placeholder="Select a member" />
              </SelectTrigger>
              <SelectContent>
                {membersResponse?.data.map((member) => (
                  <SelectItem key={member.id} value={String(member.id)}>
                    {member.full_name} ({member.member_code})
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <Label htmlFor="amount">Amount</Label>
            <Input
              id="amount"
              type="number"
              min="0.01"
              step="0.01"
              required
              value={amount}
              onChange={(event) => setAmount(event.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label>Payment Method</Label>
            <Select value={method} onValueChange={(value) => setMethod(value ?? "cash")}>
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {PAYMENT_METHODS.map((paymentMethod) => (
                  <SelectItem key={paymentMethod} value={paymentMethod}>
                    {paymentMethod.replace("_", " ")}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <Button type="submit" className="w-full" disabled={createPayment.isPending}>
            {createPayment.isPending ? "Processing..." : "Record Payment"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
