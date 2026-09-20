import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse, SubscriptionPlanTier } from "@/lib/api-types";

export function useSubscriptionPlans() {
  return useQuery({
    queryKey: ["subscription-plans"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<SubscriptionPlanTier[]>>(
        "/subscription-plans",
      );
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}

export interface SubscriptionPlanFormValues {
  name: string;
  description?: string;
  member_limit?: number | null;
  price?: number | null;
  status?: "active" | "inactive";
}

export function useCreateSubscriptionPlan() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: SubscriptionPlanFormValues) => {
      const { data } = await apiClient.post<ApiResponse<SubscriptionPlanTier>>(
        "/subscription-plans",
        values,
      );
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["subscription-plans"] });
    },
  });
}

export function useUpdateSubscriptionPlan(planId: number) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: SubscriptionPlanFormValues) => {
      const { data } = await apiClient.put<ApiResponse<SubscriptionPlanTier>>(
        `/subscription-plans/${planId}`,
        values,
      );
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["subscription-plans"] });
    },
  });
}

export function useDeleteSubscriptionPlan() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (planId: number) => {
      const { data } = await apiClient.delete<ApiResponse<{ message: string }>>(
        `/subscription-plans/${planId}`,
      );
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["subscription-plans"] });
    },
  });
}
