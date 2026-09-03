import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse, WorkoutExercise, WorkoutPlan } from "@/lib/api-types";

export function useWorkoutPlans(memberId: number) {
  return useQuery({
    queryKey: ["workout-plans", memberId],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<WorkoutPlan[]>>("/workout-plans", {
        params: { member_id: memberId },
      });
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    enabled: !!memberId,
  });
}

export interface WorkoutPlanFormValues {
  member_id: number;
  trainer_id?: number;
  name: string;
  notes?: string;
  exercises: Omit<WorkoutExercise, "id">[];
}

export function useCreateWorkoutPlan() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: WorkoutPlanFormValues) => {
      const { data } = await apiClient.post<ApiResponse<WorkoutPlan>>("/workout-plans", values);
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: (_, variables) => {
      void queryClient.invalidateQueries({ queryKey: ["workout-plans", variables.member_id] });
    },
  });
}
