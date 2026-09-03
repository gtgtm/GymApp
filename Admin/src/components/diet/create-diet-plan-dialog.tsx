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
import { Plus, Trash2 } from "lucide-react";
import { useCreateDietPlan } from "@/hooks/use-diet-plans";
import type { DietMeal, MealSlot } from "@/lib/api-types";
import { toast } from "sonner";

const MEAL_SLOTS: { value: MealSlot; label: string }[] = [
  { value: "breakfast", label: "Breakfast" },
  { value: "mid_morning", label: "Mid Morning" },
  { value: "lunch", label: "Lunch" },
  { value: "evening_snack", label: "Evening Snack" },
  { value: "dinner", label: "Dinner" },
  { value: "before_bed", label: "Before Bed" },
];

type DraftMeal = Omit<DietMeal, "id">;

const EMPTY_MEAL: DraftMeal = {
  meal_slot: "breakfast",
  food_item: "",
  quantity: "",
  calories: "",
  protein_g: "",
  carbs_g: "",
  fat_g: "",
  notes: "",
};

export function CreateDietPlanDialog({ memberId }: { memberId: number }) {
  const [open, setOpen] = useState(false);
  const [name, setName] = useState("");
  const [meals, setMeals] = useState<DraftMeal[]>([{ ...EMPTY_MEAL }]);
  const createPlan = useCreateDietPlan();

  function updateMeal(index: number, patch: Partial<DraftMeal>) {
    setMeals((prev) => prev.map((meal, i) => (i === index ? { ...meal, ...patch } : meal)));
  }

  function addMeal() {
    setMeals((prev) => [...prev, { ...EMPTY_MEAL }]);
  }

  function removeMeal(index: number) {
    setMeals((prev) => prev.filter((_, i) => i !== index));
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    try {
      await createPlan.mutateAsync({
        member_id: memberId,
        name,
        meals,
      });
      toast.success("Diet plan created.");
      setOpen(false);
      setName("");
      setMeals([{ ...EMPTY_MEAL }]);
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to create diet plan.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger render={<Button>Add Diet Plan</Button>} />
      <DialogContent className="max-h-[85vh] max-w-2xl overflow-y-auto sm:max-w-2xl">
        <DialogHeader>
          <DialogTitle>Create Diet Plan</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="diet_plan_name">Plan Name</Label>
            <Input
              id="diet_plan_name"
              required
              value={name}
              onChange={(e) => setName(e.target.value)}
            />
          </div>

          <div className="space-y-3">
            {meals.map((meal, index) => (
              <div key={index} className="space-y-2 rounded-lg border p-3">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium">Meal {index + 1}</span>
                  {meals.length > 1 && (
                    <Button
                      type="button"
                      variant="ghost"
                      size="icon-sm"
                      onClick={() => removeMeal(index)}
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  )}
                </div>
                <div className="grid grid-cols-2 gap-2">
                  <Select
                    value={meal.meal_slot}
                    onValueChange={(value) =>
                      updateMeal(index, { meal_slot: (value ?? "breakfast") as MealSlot })
                    }
                  >
                    <SelectTrigger className="col-span-2">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {MEAL_SLOTS.map((slot) => (
                        <SelectItem key={slot.value} value={slot.value}>
                          {slot.label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <Input
                    placeholder="Food item"
                    required
                    className="col-span-2"
                    value={meal.food_item}
                    onChange={(e) => updateMeal(index, { food_item: e.target.value })}
                  />
                  <Input
                    placeholder="Quantity (e.g. 1 bowl)"
                    value={meal.quantity ?? ""}
                    onChange={(e) => updateMeal(index, { quantity: e.target.value })}
                  />
                  <Input
                    type="number"
                    placeholder="Calories"
                    value={meal.calories ?? ""}
                    onChange={(e) => updateMeal(index, { calories: e.target.value })}
                  />
                  <Input
                    type="number"
                    placeholder="Protein (g)"
                    value={meal.protein_g ?? ""}
                    onChange={(e) => updateMeal(index, { protein_g: e.target.value })}
                  />
                  <Input
                    type="number"
                    placeholder="Carbs (g)"
                    value={meal.carbs_g ?? ""}
                    onChange={(e) => updateMeal(index, { carbs_g: e.target.value })}
                  />
                  <Input
                    type="number"
                    placeholder="Fat (g)"
                    value={meal.fat_g ?? ""}
                    onChange={(e) => updateMeal(index, { fat_g: e.target.value })}
                  />
                </div>
              </div>
            ))}
            <Button type="button" variant="outline" size="sm" onClick={addMeal}>
              <Plus className="h-4 w-4" />
              Add Meal
            </Button>
          </div>

          <Button type="submit" className="w-full" disabled={createPlan.isPending}>
            {createPlan.isPending ? "Saving..." : "Save Diet Plan"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
