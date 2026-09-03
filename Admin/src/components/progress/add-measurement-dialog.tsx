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
import { useCreateBodyMeasurement } from "@/hooks/use-progress";
import { toast } from "sonner";

const TODAY = new Date().toISOString().slice(0, 10);

export function AddMeasurementDialog({ memberId }: { memberId: number }) {
  const [open, setOpen] = useState(false);
  const [recordedDate, setRecordedDate] = useState(TODAY);
  const [weightKg, setWeightKg] = useState("");
  const [heightCm, setHeightCm] = useState("");
  const [bodyFatPercent, setBodyFatPercent] = useState("");
  const [chestCm, setChestCm] = useState("");
  const [waistCm, setWaistCm] = useState("");
  const [armsCm, setArmsCm] = useState("");
  const [thighCm, setThighCm] = useState("");
  const [hipsCm, setHipsCm] = useState("");
  const createMeasurement = useCreateBodyMeasurement();

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    try {
      await createMeasurement.mutateAsync({
        member_id: memberId,
        recorded_date: recordedDate,
        weight_kg: weightKg ? Number(weightKg) : undefined,
        height_cm: heightCm ? Number(heightCm) : undefined,
        body_fat_percent: bodyFatPercent ? Number(bodyFatPercent) : undefined,
        chest_cm: chestCm ? Number(chestCm) : undefined,
        waist_cm: waistCm ? Number(waistCm) : undefined,
        arms_cm: armsCm ? Number(armsCm) : undefined,
        thigh_cm: thighCm ? Number(thighCm) : undefined,
        hips_cm: hipsCm ? Number(hipsCm) : undefined,
      });
      toast.success("Measurement recorded.");
      setOpen(false);
      setWeightKg("");
      setBodyFatPercent("");
      setChestCm("");
      setWaistCm("");
      setArmsCm("");
      setThighCm("");
      setHipsCm("");
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to record measurement.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger render={<Button>Add Measurement</Button>} />
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Add Body Measurement</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="recorded_date">Date</Label>
            <Input
              id="recorded_date"
              type="date"
              required
              value={recordedDate}
              onChange={(e) => setRecordedDate(e.target.value)}
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="weight_kg">Weight (kg)</Label>
              <Input
                id="weight_kg"
                type="number"
                step="0.1"
                value={weightKg}
                onChange={(e) => setWeightKg(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="height_cm">Height (cm)</Label>
              <Input
                id="height_cm"
                type="number"
                step="0.1"
                value={heightCm}
                onChange={(e) => setHeightCm(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="body_fat">Body Fat %</Label>
              <Input
                id="body_fat"
                type="number"
                step="0.1"
                value={bodyFatPercent}
                onChange={(e) => setBodyFatPercent(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="chest_cm">Chest (cm)</Label>
              <Input
                id="chest_cm"
                type="number"
                step="0.1"
                value={chestCm}
                onChange={(e) => setChestCm(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="waist_cm">Waist (cm)</Label>
              <Input
                id="waist_cm"
                type="number"
                step="0.1"
                value={waistCm}
                onChange={(e) => setWaistCm(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="arms_cm">Arms (cm)</Label>
              <Input
                id="arms_cm"
                type="number"
                step="0.1"
                value={armsCm}
                onChange={(e) => setArmsCm(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="thigh_cm">Thigh (cm)</Label>
              <Input
                id="thigh_cm"
                type="number"
                step="0.1"
                value={thighCm}
                onChange={(e) => setThighCm(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="hips_cm">Hips (cm)</Label>
              <Input
                id="hips_cm"
                type="number"
                step="0.1"
                value={hipsCm}
                onChange={(e) => setHipsCm(e.target.value)}
              />
            </div>
          </div>
          <Button type="submit" className="w-full" disabled={createMeasurement.isPending}>
            {createMeasurement.isPending ? "Saving..." : "Save Measurement"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
