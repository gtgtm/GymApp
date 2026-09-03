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
import { useCreateTrial } from "@/hooks/use-trials";
import { toast } from "sonner";

const TODAY = new Date().toISOString().slice(0, 10);

function daysFromNow(days: number): string {
  const date = new Date();
  date.setDate(date.getDate() + days);
  return date.toISOString().slice(0, 10);
}

export function CreateTrialDialog({ defaultOpen = false }: { defaultOpen?: boolean }) {
  const [open, setOpen] = useState(defaultOpen);
  const [name, setName] = useState("");
  const [mobile, setMobile] = useState("");
  const [trialStart, setTrialStart] = useState(TODAY);
  const [trialEnd, setTrialEnd] = useState(daysFromNow(3));
  const createTrial = useCreateTrial();

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    try {
      await createTrial.mutateAsync({
        name,
        mobile,
        trial_start: trialStart,
        trial_end: trialEnd,
      });
      toast.success("Trial created.");
      setOpen(false);
      setName("");
      setMobile("");
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to create trial.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger render={<Button>Add Trial</Button>} />
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Create Trial</DialogTitle>
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
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="trial_start">Trial Start</Label>
              <Input
                id="trial_start"
                type="date"
                required
                value={trialStart}
                onChange={(e) => setTrialStart(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="trial_end">Trial End</Label>
              <Input
                id="trial_end"
                type="date"
                required
                value={trialEnd}
                onChange={(e) => setTrialEnd(e.target.value)}
              />
            </div>
          </div>
          <Button type="submit" className="w-full" disabled={createTrial.isPending}>
            {createTrial.isPending ? "Saving..." : "Save Trial"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
