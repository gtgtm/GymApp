import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse, Subscription, SubscriptionPlan } from "@/lib/api-types";

export function useSubscriptions() {
  return useQuery({
    queryKey: ["subscriptions"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<Subscription[]>>("/subscriptions");
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}

export interface SubscriptionFormValues {
  gym_id: number;
  plan: SubscriptionPlan;
  start_date: string;
  expiry_date: string;
  payment_status?: "active" | "past_due" | "cancelled";
}

export function useCreateSubscription() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: SubscriptionFormValues) => {
      const { data } = await apiClient.post<ApiResponse<Subscription>>("/subscriptions", values);
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["subscriptions"] });
      void queryClient.invalidateQueries({ queryKey: ["platform", "gyms"] });
    },
  });
}

export interface UpdateSubscriptionFormValues {
  plan?: SubscriptionPlan;
  start_date?: string;
  expiry_date?: string;
  payment_status?: "active" | "past_due" | "cancelled";
}

export function useUpdateSubscription(subscriptionId: number) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: UpdateSubscriptionFormValues) => {
      const { data } = await apiClient.put<ApiResponse<Subscription>>(
        `/subscriptions/${subscriptionId}`,
        values,
      );
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["subscriptions"] });
      void queryClient.invalidateQueries({ queryKey: ["platform", "gyms"] });
    },
  });
}
