import { useQuery } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse, Subscription } from "@/lib/api-types";

export function useMySubscription() {
  return useQuery({
    queryKey: ["subscription", "mine"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<Subscription | null>>(
        "/subscriptions/mine",
      );
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}
