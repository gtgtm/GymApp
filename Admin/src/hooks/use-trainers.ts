import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse, Trainer } from "@/lib/api-types";

export function useTrainers() {
  return useQuery({
    queryKey: ["trainers"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<Trainer[]>>("/trainers");
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}

export function useTrainer(id: number | null) {
  return useQuery({
    queryKey: ["trainers", id],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<Trainer>>(`/trainers/${id}`);
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    enabled: id !== null,
  });
}

export interface TrainerFormValues {
  name: string;
  email: string;
  phone?: string;
  password: string;
  specialization?: string;
  joining_date?: string;
  salary?: number;
}

export function useCreateTrainer() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: TrainerFormValues) => {
      const { data } = await apiClient.post<ApiResponse<Trainer>>("/trainers", values);
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["trainers"] });
    },
  });
}
