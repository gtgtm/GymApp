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
import { useCreateEquipment } from "@/hooks/use-equipment";
import type { EquipmentCondition } from "@/lib/api-types";
import { toast } from "sonner";

const CONDITIONS: EquipmentCondition[] = ["good", "fair", "needs_repair", "out_of_service"];

export function CreateEquipmentDialog({ defaultOpen = false }: { defaultOpen?: boolean }) {
  const [open, setOpen] = useState(defaultOpen);
  const [name, setName] = useState("");
  const [category, setCategory] = useState("");
  const [purchasePrice, setPurchasePrice] = useState("");
  const [condition, setCondition] = useState<EquipmentCondition>("good");
  const [nextMaintenanceDate, setNextMaintenanceDate] = useState("");
  const createEquipment = useCreateEquipment();

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    try {
      await createEquipment.mutateAsync({
        name,
        category: category || undefined,
        purchase_price: purchasePrice ? Number(purchasePrice) : undefined,
        condition,
        next_maintenance_date: nextMaintenanceDate || undefined,
      });
      toast.success("Equipment added.");
      setOpen(false);
      setName("");
      setCategory("");
      setPurchasePrice("");
      setNextMaintenanceDate("");
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to add equipment.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger render={<Button>Add Equipment</Button>} />
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Add Equipment</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="name">Name</Label>
            <Input id="name" required value={name} onChange={(e) => setName(e.target.value)} />
          </div>
          <div className="space-y-2">
            <Label htmlFor="category">Category (optional)</Label>
            <Input
              id="category"
              value={category}
              onChange={(e) => setCategory(e.target.value)}
              placeholder="e.g. Cardio, Strength"
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="purchase_price">Purchase Price (optional)</Label>
            <Input
              id="purchase_price"
              type="number"
              min="0"
              step="0.01"
              value={purchasePrice}
              onChange={(e) => setPurchasePrice(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label>Condition</Label>
            <Select
              value={condition}
              onValueChange={(value) => setCondition((value ?? "good") as EquipmentCondition)}
            >
              <SelectTrigger className="w-full">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {CONDITIONS.map((c) => (
                  <SelectItem key={c} value={c}>
                    {c.replace("_", " ")}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <Label htmlFor="next_maintenance_date">Next Maintenance Date (optional)</Label>
            <Input
              id="next_maintenance_date"
              type="date"
              value={nextMaintenanceDate}
              onChange={(e) => setNextMaintenanceDate(e.target.value)}
            />
          </div>
          <Button type="submit" className="w-full" disabled={createEquipment.isPending}>
            {createEquipment.isPending ? "Saving..." : "Save Equipment"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
