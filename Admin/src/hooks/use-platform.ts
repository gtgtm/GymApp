import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse, PlatformGymDetail, PlatformGymSummary } from "@/lib/api-types";

export function usePlatformGyms() {
  return useQuery({
    queryKey: ["platform", "gyms"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<PlatformGymSummary[]>>("/platform/gyms");
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}

export function usePlatformGym(id: number | null) {
  return useQuery({
    queryKey: ["platform", "gyms", id],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<PlatformGymDetail>>(`/platform/gyms/${id}`);
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    enabled: id !== null,
  });
}

export interface CreateGymFormValues {
  name: string;
  email?: string;
  phone?: string;
  address?: string;
  admin_name: string;
  admin_email: string;
  admin_password: string;
}

export function useCreateGym() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: CreateGymFormValues) => {
      const { data } = await apiClient.post<ApiResponse<PlatformGymDetail>>(
        "/platform/gyms",
        values,
      );
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["platform", "gyms"] });
    },
  });
}

export interface UpdateGymFormValues {
  name?: string;
  email?: string | null;
  phone?: string | null;
  address?: string | null;
  status?: "active" | "inactive";
}

export function useUpdateGym(gymId: number) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: UpdateGymFormValues) => {
      const { data } = await apiClient.put<ApiResponse<PlatformGymDetail>>(
        `/platform/gyms/${gymId}`,
        values,
      );
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["platform", "gyms"] });
      void queryClient.invalidateQueries({ queryKey: ["platform", "gyms", gymId] });
    },
  });
}
