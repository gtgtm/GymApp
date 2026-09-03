"use client";

import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import { useAuth } from "@/hooks/use-auth";
import type { ApiResponse, Trainer } from "@/lib/api-types";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { Button } from "@/components/ui/button";
import { CalendarCheck, Dumbbell, Salad } from "lucide-react";

export function TrainerDashboard() {
  const { user } = useAuth();

  const { data: trainers, isLoading } = useQuery({
    queryKey: ["trainers", "me"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<Trainer[]>>("/trainers");
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });

  const myTrainerProfile = trainers?.find((trainer) => trainer.user.id === user?.id);

  if (isLoading) {
    return <Skeleton className="h-64 w-full" />;
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">Welcome, {user?.name}</h1>
        <p className="text-sm text-muted-foreground">
          {myTrainerProfile?.specialization ?? "Trainer"}
        </p>
      </div>

      <div className="flex flex-wrap gap-3">
        <Button variant="outline" nativeButton={false} render={<Link href="/attendance" />}>
          <CalendarCheck className="h-4 w-4" />
          Mark Attendance
        </Button>
        <Button variant="outline" nativeButton={false} render={<Link href="/members" />}>
          <Dumbbell className="h-4 w-4" />
          Assign Workout Plan
        </Button>
        <Button variant="outline" nativeButton={false} render={<Link href="/members" />}>
          <Salad className="h-4 w-4" />
          Assign Diet Plan
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>My Assigned Members</CardTitle>
        </CardHeader>
        <CardContent>
          {!myTrainerProfile || (myTrainerProfile.assigned_members_count ?? 0) === 0 ? (
            <p className="text-sm text-muted-foreground">No members assigned to you yet.</p>
          ) : (
            <p className="text-sm text-muted-foreground">
              You have {myTrainerProfile.assigned_members_count} assigned member
              {myTrainerProfile.assigned_members_count === 1 ? "" : "s"}. View them from the{" "}
              <Link href="/members" className="underline">
                Members
              </Link>{" "}
              page to manage workout plans, diet plans, and progress.
            </p>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
