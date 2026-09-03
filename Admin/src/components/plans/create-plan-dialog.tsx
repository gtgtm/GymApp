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
import { useCreatePlan } from "@/hooks/use-plans";
import { toast } from "sonner";

export function CreatePlanDialog({ defaultOpen = false }: { defaultOpen?: boolean }) {
  const [open, setOpen] = useState(defaultOpen);
  const [name, setName] = useState("");
  const [durationDays, setDurationDays] = useState("30");
  const [price, setPrice] = useState("");
  const [registrationFee, setRegistrationFee] = useState("0");
  const [discount, setDiscount] = useState("0");
  const [tax, setTax] = useState("0");
  const createPlan = useCreatePlan();

  const totalAmount =
    Number(price || 0) + Number(registrationFee || 0) - Number(discount || 0) + Number(tax || 0);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    try {
      await createPlan.mutateAsync({
        name,
        duration_days: Number(durationDays),
        price: Number(price),
        registration_fee: Number(registrationFee),
        discount: Number(discount),
        tax: Number(tax),
        total_amount: totalAmount,
      });
      toast.success("Membership plan created.");
      setOpen(false);
      setName("");
      setPrice("");
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to create plan.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger render={<Button>Add Plan</Button>} />
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Create Membership Plan</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="name">Plan Name</Label>
            <Input id="name" required value={name} onChange={(e) => setName(e.target.value)} />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="duration">Duration (days)</Label>
              <Input
                id="duration"
                type="number"
                required
                value={durationDays}
                onChange={(e) => setDurationDays(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="price">Price</Label>
              <Input
                id="price"
                type="number"
                step="0.01"
                required
                value={price}
                onChange={(e) => setPrice(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="registration_fee">Registration Fee</Label>
              <Input
                id="registration_fee"
                type="number"
                step="0.01"
                value={registrationFee}
                onChange={(e) => setRegistrationFee(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="discount">Discount</Label>
              <Input
                id="discount"
                type="number"
                step="0.01"
                value={discount}
                onChange={(e) => setDiscount(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="tax">Tax</Label>
              <Input
                id="tax"
                type="number"
                step="0.01"
                value={tax}
                onChange={(e) => setTax(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label>Total Amount</Label>
              <Input readOnly value={totalAmount.toFixed(2)} />
            </div>
          </div>
          <Button type="submit" className="w-full" disabled={createPlan.isPending}>
            {createPlan.isPending ? "Saving..." : "Save Plan"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
