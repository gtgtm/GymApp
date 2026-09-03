import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse, Payment } from "@/lib/api-types";

export function usePayments() {
  return useQuery({
    queryKey: ["payments"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<Payment[]>>("/payments");
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}

export interface PaymentFormValues {
  member_id: number;
  amount: number;
  discount?: number;
  tax?: number;
  method: string;
}

export function useCreatePayment() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: PaymentFormValues) => {
      const { data } = await apiClient.post<ApiResponse<Payment>>("/payments", values);
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["payments"] });
      void queryClient.invalidateQueries({ queryKey: ["dashboard"] });
    },
  });
}
