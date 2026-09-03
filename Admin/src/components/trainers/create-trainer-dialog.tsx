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
import { useCreateTrainer } from "@/hooks/use-trainers";
import { toast } from "sonner";

export function CreateTrainerDialog({ defaultOpen = false }: { defaultOpen?: boolean }) {
  const [open, setOpen] = useState(defaultOpen);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");
  const [specialization, setSpecialization] = useState("");
  const createTrainer = useCreateTrainer();

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    try {
      await createTrainer.mutateAsync({
        name,
        email,
        phone: phone || undefined,
        password,
        specialization: specialization || undefined,
      });
      toast.success("Trainer added successfully.");
      setOpen(false);
      setName("");
      setEmail("");
      setPhone("");
      setPassword("");
      setSpecialization("");
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to add trainer.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger render={<Button>Add Trainer</Button>} />
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Add Trainer</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="name">Full Name</Label>
            <Input id="name" required value={name} onChange={(e) => setName(e.target.value)} />
          </div>
          <div className="space-y-2">
            <Label htmlFor="email">Email</Label>
            <Input
              id="email"
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="phone">Phone (optional)</Label>
            <Input id="phone" value={phone} onChange={(e) => setPhone(e.target.value)} />
          </div>
          <div className="space-y-2">
            <Label htmlFor="password">Password</Label>
            <Input
              id="password"
              type="password"
              required
              minLength={8}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="specialization">Specialization (optional)</Label>
            <Input
              id="specialization"
              value={specialization}
              onChange={(e) => setSpecialization(e.target.value)}
              placeholder="e.g. Strength & Conditioning"
            />
          </div>
          <Button type="submit" className="w-full" disabled={createTrainer.isPending}>
            {createTrainer.isPending ? "Saving..." : "Save Trainer"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
