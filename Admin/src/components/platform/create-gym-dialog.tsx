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
import { useCreateGym } from "@/hooks/use-platform";
import { toast } from "sonner";
import { Plus } from "lucide-react";

export function CreateGymDialog() {
  const [open, setOpen] = useState(false);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [address, setAddress] = useState("");
  const [adminName, setAdminName] = useState("");
  const [adminEmail, setAdminEmail] = useState("");
  const [adminPassword, setAdminPassword] = useState("");
  const createGym = useCreateGym();

  function reset() {
    setName("");
    setEmail("");
    setPhone("");
    setAddress("");
    setAdminName("");
    setAdminEmail("");
    setAdminPassword("");
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    try {
      await createGym.mutateAsync({
        name,
        email: email || undefined,
        phone: phone || undefined,
        address: address || undefined,
        admin_name: adminName,
        admin_email: adminEmail,
        admin_password: adminPassword,
      });
      toast.success(`${name} added to the platform.`);
      setOpen(false);
      reset();
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to add gym.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger
        render={
          <Button className="gap-1.5">
            <Plus className="h-4 w-4" />
            Add Gym
          </Button>
        }
      />
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Add Gym</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="gym_name">Gym Name</Label>
            <Input id="gym_name" required value={name} onChange={(e) => setName(e.target.value)} />
          </div>
          <div className="space-y-2">
            <Label htmlFor="gym_email">Email (optional)</Label>
            <Input
              id="gym_email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="gym_phone">Phone (optional)</Label>
            <Input id="gym_phone" value={phone} onChange={(e) => setPhone(e.target.value)} />
          </div>
          <div className="space-y-2">
            <Label htmlFor="gym_address">Address (optional)</Label>
            <Input id="gym_address" value={address} onChange={(e) => setAddress(e.target.value)} />
          </div>

          <div className="space-y-2 border-t pt-4">
            <p className="text-sm font-medium">First Admin Account</p>
            <p className="text-xs text-muted-foreground">
              This gym&rsquo;s admin will sign in with these credentials.
            </p>
          </div>
          <div className="space-y-2">
            <Label htmlFor="admin_name">Admin Name</Label>
            <Input
              id="admin_name"
              required
              value={adminName}
              onChange={(e) => setAdminName(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="admin_email">Admin Email</Label>
            <Input
              id="admin_email"
              type="email"
              required
              value={adminEmail}
              onChange={(e) => setAdminEmail(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="admin_password">Admin Password</Label>
            <Input
              id="admin_password"
              type="password"
              required
              minLength={8}
              value={adminPassword}
              onChange={(e) => setAdminPassword(e.target.value)}
            />
          </div>

          <Button type="submit" className="w-full" disabled={createGym.isPending}>
            {createGym.isPending ? "Creating..." : "Create Gym"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
