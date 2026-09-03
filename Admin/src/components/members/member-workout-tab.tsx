"use client";

import { useWorkoutPlans } from "@/hooks/use-workout-plans";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { CreateWorkoutPlanDialog } from "@/components/workouts/create-workout-plan-dialog";

export function MemberWorkoutTab({ memberId }: { memberId: number }) {
  const { data: plans, isLoading } = useWorkoutPlans(memberId);

  if (isLoading) {
    return <Skeleton className="h-64 w-full" />;
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <CreateWorkoutPlanDialog memberId={memberId} />
      </div>

      {plans?.length === 0 && (
        <p className="text-sm text-muted-foreground">No workout plan assigned yet.</p>
      )}

      {plans?.map((plan) => {
        const exercisesByDay = plan.exercises.reduce<Record<number, typeof plan.exercises>>(
          (acc, exercise) => {
            acc[exercise.day_number] = [...(acc[exercise.day_number] ?? []), exercise];
            return acc;
          },
          {},
        );

        return (
          <Card key={plan.id}>
            <CardHeader className="flex flex-row items-center justify-between">
              <CardTitle>{plan.name}</CardTitle>
              <Badge variant={plan.status === "active" ? "default" : "secondary"}>
                {plan.status}
              </Badge>
            </CardHeader>
            <CardContent className="space-y-4">
              {Object.entries(exercisesByDay).map(([day, exercises]) => (
                <div key={day} className="space-y-2">
                  <p className="text-sm font-semibold">
                    Day {day}
                    {exercises[0].day_label ? ` — ${exercises[0].day_label}` : ""}
                  </p>
                  <ul className="space-y-1">
                    {exercises.map((exercise) => (
                      <li
                        key={exercise.id}
                        className="flex flex-wrap items-center justify-between gap-2 rounded-md bg-muted/50 px-3 py-2 text-sm"
                      >
                        <span className="font-medium">{exercise.exercise_name}</span>
                        <span className="text-muted-foreground">
                          {exercise.muscle_group && `${exercise.muscle_group} · `}
                          {exercise.sets && `${exercise.sets} sets`}
                          {exercise.reps && ` × ${exercise.reps}`}
                          {exercise.weight_kg && ` @ ${exercise.weight_kg}kg`}
                        </span>
                      </li>
                    ))}
                  </ul>
                </div>
              ))}
            </CardContent>
          </Card>
        );
      })}
    </div>
  );
}
