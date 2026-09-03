import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse, MembershipPlan } from "@/lib/api-types";

export function usePlans() {
  return useQuery({
    queryKey: ["plans"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<MembershipPlan[]>>("/membership-plans");
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}

export interface PlanFormValues {
  name: string;
  duration_days: number;
  price: number;
  registration_fee?: number;
  discount?: number;
  tax?: number;
  total_amount: number;
  description?: string;
  benefits?: string[];
  freeze_days?: number;
  status?: "active" | "inactive";
}

export function useCreatePlan() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: PlanFormValues) => {
      const { data } = await apiClient.post<ApiResponse<MembershipPlan>>(
        "/membership-plans",
        values,
      );
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["plans"] });
    },
  });
}
