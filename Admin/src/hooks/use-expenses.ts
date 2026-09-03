import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse, Expense, ExpenseCategory } from "@/lib/api-types";

export function useExpenses() {
  return useQuery({
    queryKey: ["expenses"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<Expense[]>>("/expenses");
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}

export interface ExpenseFormValues {
  category: ExpenseCategory;
  amount: number;
  expense_date: string;
  description?: string;
  payment_method?: string;
}

export function useCreateExpense() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: ExpenseFormValues) => {
      const { data } = await apiClient.post<ApiResponse<Expense>>("/expenses", values);
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["expenses"] });
      void queryClient.invalidateQueries({ queryKey: ["dashboard"] });
    },
  });
}
