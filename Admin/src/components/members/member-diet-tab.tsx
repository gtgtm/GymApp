"use client";

import { useDietPlans } from "@/hooks/use-diet-plans";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { CreateDietPlanDialog } from "@/components/diet/create-diet-plan-dialog";

const MEAL_SLOT_LABELS: Record<string, string> = {
  breakfast: "Breakfast",
  mid_morning: "Mid Morning",
  lunch: "Lunch",
  evening_snack: "Evening Snack",
  dinner: "Dinner",
  before_bed: "Before Bed",
};

export function MemberDietTab({ memberId }: { memberId: number }) {
  const { data: plans, isLoading } = useDietPlans(memberId);

  if (isLoading) {
    return <Skeleton className="h-64 w-full" />;
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <CreateDietPlanDialog memberId={memberId} />
      </div>

      {plans?.length === 0 && (
        <p className="text-sm text-muted-foreground">No diet plan assigned yet.</p>
      )}

      {plans?.map((plan) => (
        <Card key={plan.id}>
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle>{plan.name}</CardTitle>
            <Badge variant={plan.status === "active" ? "default" : "secondary"}>
              {plan.status}
            </Badge>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-4 gap-2 rounded-md bg-muted/50 p-3 text-center text-sm">
              <div>
                <p className="font-semibold">{plan.daily_summary.calories}</p>
                <p className="text-xs text-muted-foreground">kcal</p>
              </div>
              <div>
                <p className="font-semibold">{plan.daily_summary.protein_g}g</p>
                <p className="text-xs text-muted-foreground">Protein</p>
              </div>
              <div>
                <p className="font-semibold">{plan.daily_summary.carbs_g}g</p>
                <p className="text-xs text-muted-foreground">Carbs</p>
              </div>
              <div>
                <p className="font-semibold">{plan.daily_summary.fat_g}g</p>
                <p className="text-xs text-muted-foreground">Fat</p>
              </div>
            </div>
            <ul className="space-y-1">
              {plan.meals.map((meal) => (
                <li
                  key={meal.id}
                  className="flex flex-wrap items-center justify-between gap-2 rounded-md bg-muted/50 px-3 py-2 text-sm"
                >
                  <span>
                    <span className="font-medium">
                      {MEAL_SLOT_LABELS[meal.meal_slot] ?? meal.meal_slot}
                    </span>
                    {" — "}
                    {meal.food_item}
                    {meal.quantity && ` (${meal.quantity})`}
                  </span>
                  <span className="text-muted-foreground">
                    {meal.calories && `${meal.calories} kcal`}
                  </span>
                </li>
              ))}
            </ul>
          </CardContent>
        </Card>
      ))}
    </div>
  );
}
