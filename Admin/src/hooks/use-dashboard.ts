import { useQuery } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse, DashboardResponse } from "@/lib/api-types";

export function useDashboard() {
  return useQuery({
    queryKey: ["dashboard"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<DashboardResponse>>("/dashboard");
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}
