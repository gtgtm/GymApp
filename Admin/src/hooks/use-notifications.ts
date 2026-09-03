import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse, GymNotification } from "@/lib/api-types";

export function useNotifications() {
  return useQuery({
    queryKey: ["notifications"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<GymNotification[]>>("/notifications");
      if (!data.success) throw new Error(data.error.message);
      return { notifications: data.data, unreadCount: (data.meta as { unread_count: number } | undefined)?.unread_count ?? 0 };
    },
    refetchInterval: 60_000,
  });
}

export function useMarkNotificationRead() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (id: number) => {
      const { data } = await apiClient.put<ApiResponse<GymNotification>>(`/notifications/${id}/read`);
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["notifications"] });
    },
  });
}

export function useMarkAllNotificationsRead() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async () => {
      const { data } = await apiClient.post<ApiResponse<{ message: string }>>(
        "/notifications/mark-all-read",
      );
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["notifications"] });
    },
  });
}
