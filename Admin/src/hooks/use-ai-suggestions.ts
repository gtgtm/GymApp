import { useQuery } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { AiSuggestion, ApiResponse } from "@/lib/api-types";

export function useAiSuggestions() {
  return useQuery({
    queryKey: ["ai-suggestions"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<AiSuggestion[]>>("/ai/suggestions");
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}
