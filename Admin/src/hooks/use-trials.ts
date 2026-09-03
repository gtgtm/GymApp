import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse, Trial } from "@/lib/api-types";

export function useTrials() {
  return useQuery({
    queryKey: ["trials"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<Trial[]>>("/trials");
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}

export function useExpiringSoonTrials() {
  return useQuery({
    queryKey: ["trials-expiring-soon"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<Trial[]>>("/trials-expiring-soon");
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}

export interface TrialFormValues {
  name: string;
  mobile: string;
  trial_start: string;
  trial_end: string;
  trainer_id?: number;
}

export function useCreateTrial() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: TrialFormValues) => {
      const { data } = await apiClient.post<ApiResponse<Trial>>("/trials", values);
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["trials"] });
      void queryClient.invalidateQueries({ queryKey: ["trials-expiring-soon"] });
    },
  });
}

export function useUpdateTrialStatus() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, status }: { id: number; status: string }) => {
      const { data } = await apiClient.put<ApiResponse<Trial>>(`/trials/${id}`, { status });
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["trials"] });
      void queryClient.invalidateQueries({ queryKey: ["trials-expiring-soon"] });
    },
  });
}
