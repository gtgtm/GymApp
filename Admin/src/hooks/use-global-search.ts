import { useQuery } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse, GlobalSearchResults } from "@/lib/api-types";

export function useGlobalSearch(query: string) {
  return useQuery({
    queryKey: ["global-search", query],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<GlobalSearchResults>>("/search", {
        params: { q: query },
      });
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    enabled: query.trim().length >= 2,
  });
}
