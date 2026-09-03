import { useQuery } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type {
  ApiResponse,
  AttendanceReport,
  FinancialReport,
  MembersReport,
  SalesReport,
  TrainerReportRow,
} from "@/lib/api-types";

interface DateRange {
  from: string;
  to: string;
}

export function useFinancialReport(range: DateRange) {
  return useQuery({
    queryKey: ["reports", "financial", range],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<FinancialReport>>("/reports/financial", {
        params: range,
      });
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}

export function useMembersReport(range: DateRange) {
  return useQuery({
    queryKey: ["reports", "members", range],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<MembersReport>>("/reports/members", {
        params: range,
      });
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}

export function useAttendanceReport(range: DateRange) {
  return useQuery({
    queryKey: ["reports", "attendance", range],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<AttendanceReport>>("/reports/attendance", {
        params: range,
      });
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}

export function useTrainerReport() {
  return useQuery({
    queryKey: ["reports", "trainers"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<TrainerReportRow[]>>("/reports/trainers");
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}

export function useSalesReport(range: DateRange) {
  return useQuery({
    queryKey: ["reports", "sales", range],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<SalesReport>>("/reports/sales", {
        params: range,
      });
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}

export async function downloadReport(
  report: "financial" | "members" | "attendance" | "trainers" | "sales",
  format: "csv" | "pdf",
  range?: DateRange,
): Promise<void> {
  const response = await apiClient.get(`/reports/${report}/export/${format}`, {
    params: range,
    responseType: "blob",
  });

  const blobUrl = window.URL.createObjectURL(response.data as Blob);
  const link = document.createElement("a");
  link.href = blobUrl;
  link.download = `${report}-report.${format}`;
  document.body.appendChild(link);
  link.click();
  link.remove();
  window.URL.revokeObjectURL(blobUrl);
}
