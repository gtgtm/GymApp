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
import { useCreateEnquiry } from "@/hooks/use-enquiries";
import { toast } from "sonner";

export function CreateEnquiryDialog({ defaultOpen = false }: { defaultOpen?: boolean }) {
  const [open, setOpen] = useState(defaultOpen);
  const [name, setName] = useState("");
  const [mobile, setMobile] = useState("");
  const [source, setSource] = useState("");
  const [planId, setPlanId] = useState<string>("");
  const [followUpDate, setFollowUpDate] = useState("");
  const { data: plans } = usePlans();
  const createEnquiry = useCreateEnquiry();

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    try {
      await createEnquiry.mutateAsync({
        name,
        mobile,
        source: source || undefined,
        interested_plan_id: planId ? Number(planId) : undefined,
        follow_up_date: followUpDate || undefined,
      });
      toast.success("Enquiry added.");
      setOpen(false);
      setName("");
      setMobile("");
      setSource("");
      setPlanId("");
      setFollowUpDate("");
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to add enquiry.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger render={<Button>Add Enquiry</Button>} />
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Add Enquiry</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="name">Name</Label>
            <Input id="name" required value={name} onChange={(e) => setName(e.target.value)} />
          </div>
          <div className="space-y-2">
            <Label htmlFor="mobile">Mobile</Label>
            <Input
              id="mobile"
              required
              value={mobile}
              onChange={(e) => setMobile(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="source">Source (optional)</Label>
            <Input
              id="source"
              value={source}
              onChange={(e) => setSource(e.target.value)}
              placeholder="e.g. Walk-in, Instagram, Referral"
            />
          </div>
          <div className="space-y-2">
            <Label>Interested Plan (optional)</Label>
            <Select value={planId} onValueChange={(value) => setPlanId(value ?? "")}>
              <SelectTrigger className="w-full">
                <SelectValue placeholder="Select a plan" />
              </SelectTrigger>
              <SelectContent>
                {plans?.map((plan) => (
                  <SelectItem key={plan.id} value={String(plan.id)}>
                    {plan.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <Label htmlFor="follow_up_date">Follow-up Date (optional)</Label>
            <Input
              id="follow_up_date"
              type="date"
              value={followUpDate}
              onChange={(e) => setFollowUpDate(e.target.value)}
            />
          </div>
          <Button type="submit" className="w-full" disabled={createEnquiry.isPending}>
            {createEnquiry.isPending ? "Saving..." : "Save Enquiry"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
