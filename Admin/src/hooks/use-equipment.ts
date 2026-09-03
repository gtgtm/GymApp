import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse, Equipment } from "@/lib/api-types";

export function useEquipmentList() {
  return useQuery({
    queryKey: ["equipment"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<Equipment[]>>("/equipment");
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}

export function useEquipmentMaintenanceDue() {
  return useQuery({
    queryKey: ["equipment-maintenance-due"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<Equipment[]>>(
        "/equipment-maintenance-due",
      );
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}

export interface EquipmentFormValues {
  name: string;
  category?: string;
  purchase_date?: string;
  purchase_price?: number;
  condition?: string;
  next_maintenance_date?: string;
}

export function useCreateEquipment() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: EquipmentFormValues) => {
      const { data } = await apiClient.post<ApiResponse<Equipment>>("/equipment", values);
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["equipment"] });
      void queryClient.invalidateQueries({ queryKey: ["equipment-maintenance-due"] });
    },
  });
}
