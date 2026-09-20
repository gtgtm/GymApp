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
import { useUpdateGym } from "@/hooks/use-platform";
import type { PlatformGymDetail } from "@/lib/api-types";
import { toast } from "sonner";
import { Pencil } from "lucide-react";

export function EditGymDialog({ gym }: { gym: PlatformGymDetail }) {
  const [open, setOpen] = useState(false);
  const [name, setName] = useState(gym.name);
  const [email, setEmail] = useState(gym.email ?? "");
  const [phone, setPhone] = useState(gym.phone ?? "");
  const [address, setAddress] = useState(gym.address ?? "");
  const updateGym = useUpdateGym(gym.id);

  function handleOpenChange(nextOpen: boolean) {
    setOpen(nextOpen);
    if (nextOpen) {
      setName(gym.name);
      setEmail(gym.email ?? "");
      setPhone(gym.phone ?? "");
      setAddress(gym.address ?? "");
    }
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    try {
      await updateGym.mutateAsync({
        name,
        email: email || null,
        phone: phone || null,
        address: address || null,
      });
      toast.success("Gym details updated.");
      setOpen(false);
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to update gym.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogTrigger
        render={
          <Button variant="outline" size="sm" className="gap-1.5">
            <Pencil className="h-3.5 w-3.5" />
            Edit
          </Button>
        }
      />
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Edit Gym</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="edit_gym_name">Gym Name</Label>
            <Input
              id="edit_gym_name"
              required
              value={name}
              onChange={(e) => setName(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="edit_gym_email">Email</Label>
            <Input
              id="edit_gym_email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="edit_gym_phone">Phone</Label>
            <Input id="edit_gym_phone" value={phone} onChange={(e) => setPhone(e.target.value)} />
          </div>
          <div className="space-y-2">
            <Label htmlFor="edit_gym_address">Address</Label>
            <Input
              id="edit_gym_address"
              value={address}
              onChange={(e) => setAddress(e.target.value)}
            />
          </div>
          <Button type="submit" className="w-full" disabled={updateGym.isPending}>
            {updateGym.isPending ? "Saving..." : "Save Changes"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
