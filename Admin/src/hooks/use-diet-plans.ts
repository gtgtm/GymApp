import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse, DietMeal, DietPlan } from "@/lib/api-types";

export function useDietPlans(memberId: number) {
  return useQuery({
    queryKey: ["diet-plans", memberId],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<DietPlan[]>>("/diet-plans", {
        params: { member_id: memberId },
      });
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    enabled: !!memberId,
  });
}

export interface DietPlanFormValues {
  member_id: number;
  trainer_id?: number;
  name: string;
  notes?: string;
  meals: Omit<DietMeal, "id">[];
}

export function useCreateDietPlan() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: DietPlanFormValues) => {
      const { data } = await apiClient.post<ApiResponse<DietPlan>>("/diet-plans", values);
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: (_, variables) => {
      void queryClient.invalidateQueries({ queryKey: ["diet-plans", variables.member_id] });
    },
  });
}
