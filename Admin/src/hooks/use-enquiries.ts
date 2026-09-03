import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse, ConversionStats, Enquiry, EnquiryStatus } from "@/lib/api-types";

export function useEnquiries(params: { status?: string; search?: string } = {}) {
  return useQuery({
    queryKey: ["enquiries", params],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<Enquiry[]>>("/enquiries", { params });
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}

export function useConversionStats() {
  return useQuery({
    queryKey: ["enquiries-conversion-stats"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<ConversionStats>>(
        "/enquiries-stats/conversion",
      );
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}

export interface EnquiryFormValues {
  name: string;
  mobile: string;
  email?: string;
  source?: string;
  interested_plan_id?: number;
  follow_up_date?: string;
  notes?: string;
}

export function useCreateEnquiry() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: EnquiryFormValues) => {
      const { data } = await apiClient.post<ApiResponse<Enquiry>>("/enquiries", values);
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["enquiries"] });
      void queryClient.invalidateQueries({ queryKey: ["enquiries-conversion-stats"] });
    },
  });
}

export function useUpdateEnquiryStatus() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, status }: { id: number; status: EnquiryStatus }) => {
      const { data } = await apiClient.put<ApiResponse<Enquiry>>(`/enquiries/${id}`, { status });
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["enquiries"] });
      void queryClient.invalidateQueries({ queryKey: ["enquiries-conversion-stats"] });
    },
  });
}
