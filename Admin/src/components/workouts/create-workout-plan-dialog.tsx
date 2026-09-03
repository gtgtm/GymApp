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
import { Plus, Trash2 } from "lucide-react";
import { useCreateWorkoutPlan } from "@/hooks/use-workout-plans";
import type { WorkoutExercise } from "@/lib/api-types";
import { toast } from "sonner";

type DraftExercise = Omit<WorkoutExercise, "id" | "weight_kg"> & { weight_kg: string };

const EMPTY_EXERCISE: DraftExercise = {
  day_number: 1,
  day_label: "",
  exercise_name: "",
  muscle_group: "",
  sets: null,
  reps: "",
  weight_kg: "",
  rest_seconds: null,
  instructions: "",
  video_url: "",
  trainer_notes: "",
};

export function CreateWorkoutPlanDialog({ memberId }: { memberId: number }) {
  const [open, setOpen] = useState(false);
  const [name, setName] = useState("");
  const [exercises, setExercises] = useState<DraftExercise[]>([{ ...EMPTY_EXERCISE }]);
  const createPlan = useCreateWorkoutPlan();

  function updateExercise(index: number, patch: Partial<DraftExercise>) {
    setExercises((prev) => prev.map((ex, i) => (i === index ? { ...ex, ...patch } : ex)));
  }

  function addExercise() {
    setExercises((prev) => [...prev, { ...EMPTY_EXERCISE, day_number: prev.at(-1)?.day_number ?? 1 }]);
  }

  function removeExercise(index: number) {
    setExercises((prev) => prev.filter((_, i) => i !== index));
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    try {
      await createPlan.mutateAsync({
        member_id: memberId,
        name,
        exercises: exercises.map((ex) => ({
          ...ex,
          weight_kg: ex.weight_kg || null,
        })),
      });
      toast.success("Workout plan created.");
      setOpen(false);
      setName("");
      setExercises([{ ...EMPTY_EXERCISE }]);
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to create workout plan.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger render={<Button>Add Workout Plan</Button>} />
      <DialogContent className="max-h-[85vh] max-w-2xl overflow-y-auto sm:max-w-2xl">
        <DialogHeader>
          <DialogTitle>Create Workout Plan</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="plan_name">Plan Name</Label>
            <Input id="plan_name" required value={name} onChange={(e) => setName(e.target.value)} />
          </div>

          <div className="space-y-3">
            {exercises.map((exercise, index) => (
              <div key={index} className="space-y-2 rounded-lg border p-3">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium">Exercise {index + 1}</span>
                  {exercises.length > 1 && (
                    <Button
                      type="button"
                      variant="ghost"
                      size="icon-sm"
                      onClick={() => removeExercise(index)}
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  )}
                </div>
                <div className="grid grid-cols-2 gap-2">
                  <Input
                    type="number"
                    min={1}
                    placeholder="Day #"
                    required
                    value={exercise.day_number}
                    onChange={(e) => updateExercise(index, { day_number: Number(e.target.value) })}
                  />
                  <Input
                    placeholder="Day label (e.g. Chest & Triceps)"
                    value={exercise.day_label ?? ""}
                    onChange={(e) => updateExercise(index, { day_label: e.target.value })}
                  />
                  <Input
                    placeholder="Exercise name"
                    required
                    className="col-span-2"
                    value={exercise.exercise_name}
                    onChange={(e) => updateExercise(index, { exercise_name: e.target.value })}
                  />
                  <Input
                    placeholder="Muscle group"
                    value={exercise.muscle_group ?? ""}
                    onChange={(e) => updateExercise(index, { muscle_group: e.target.value })}
                  />
                  <Input
                    type="number"
                    placeholder="Sets"
                    value={exercise.sets ?? ""}
                    onChange={(e) =>
                      updateExercise(index, { sets: e.target.value ? Number(e.target.value) : null })
                    }
                  />
                  <Input
                    placeholder="Reps (e.g. 8-10)"
                    value={exercise.reps ?? ""}
                    onChange={(e) => updateExercise(index, { reps: e.target.value })}
                  />
                  <Input
                    type="number"
                    step="0.5"
                    placeholder="Weight (kg)"
                    value={exercise.weight_kg}
                    onChange={(e) => updateExercise(index, { weight_kg: e.target.value })}
                  />
                  <Input
                    type="number"
                    placeholder="Rest (seconds)"
                    className="col-span-2"
                    value={exercise.rest_seconds ?? ""}
                    onChange={(e) =>
                      updateExercise(index, {
                        rest_seconds: e.target.value ? Number(e.target.value) : null,
                      })
                    }
                  />
                </div>
              </div>
            ))}
            <Button type="button" variant="outline" size="sm" onClick={addExercise}>
              <Plus className="h-4 w-4" />
              Add Exercise
            </Button>
          </div>

          <Button type="submit" className="w-full" disabled={createPlan.isPending}>
            {createPlan.isPending ? "Saving..." : "Save Workout Plan"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
