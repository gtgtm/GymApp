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
import { useCreateMember } from "@/hooks/use-members";
import { toast } from "sonner";

const TODAY = new Date().toISOString().slice(0, 10);

export function CreateMemberDialog({ defaultOpen = false }: { defaultOpen?: boolean }) {
  const [open, setOpen] = useState(defaultOpen);
  const [fullName, setFullName] = useState("");
  const [mobile, setMobile] = useState("");
  const [email, setEmail] = useState("");
  const [joiningDate, setJoiningDate] = useState(TODAY);
  const createMember = useCreateMember();

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    try {
      await createMember.mutateAsync({
        full_name: fullName,
        mobile,
        email: email || undefined,
        joining_date: joiningDate,
      });
      toast.success("Member added successfully.");
      setOpen(false);
      setFullName("");
      setMobile("");
      setEmail("");
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to add member.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger render={<Button>Add Member</Button>} />
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Add Member</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="full_name">Full Name</Label>
            <Input
              id="full_name"
              required
              value={fullName}
              onChange={(event) => setFullName(event.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="mobile">Mobile Number</Label>
            <Input
              id="mobile"
              required
              value={mobile}
              onChange={(event) => setMobile(event.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="email">Email (optional)</Label>
            <Input
              id="email"
              type="email"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="joining_date">Joining Date</Label>
            <Input
              id="joining_date"
              type="date"
              required
              value={joiningDate}
              onChange={(event) => setJoiningDate(event.target.value)}
            />
          </div>
          <Button type="submit" className="w-full" disabled={createMember.isPending}>
            {createMember.isPending ? "Saving..." : "Save Member"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
