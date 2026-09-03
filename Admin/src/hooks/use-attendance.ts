import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse } from "@/lib/api-types";

interface AttendanceRecord {
  id: number;
  member_id: number;
  date: string;
  check_in_time: string | null;
  status: string;
  member?: { id: number; full_name: string; member_code: string };
}

export function useAttendance(date?: string) {
  return useQuery({
    queryKey: ["attendance", date],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<AttendanceRecord[]>>("/attendance", {
        params: date ? { date } : undefined,
      });
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });
}

interface MarkAttendanceInput {
  member_id: number;
  status?: string;
  marked_via?: string;
}

export function useMarkAttendance() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: MarkAttendanceInput) => {
      const { data } = await apiClient.post<
        ApiResponse<{ attendance: AttendanceRecord; membership_end_date: string }>
      >("/attendance", values);
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["attendance"] });
      void queryClient.invalidateQueries({ queryKey: ["dashboard"] });
    },
  });
}
