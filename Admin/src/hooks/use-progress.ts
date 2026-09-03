import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse, BodyMeasurement, ProgressPhoto } from "@/lib/api-types";

export function useBodyMeasurements(memberId: number) {
  return useQuery({
    queryKey: ["body-measurements", memberId],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<BodyMeasurement[]>>("/body-measurements", {
        params: { member_id: memberId },
      });
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    enabled: !!memberId,
  });
}

export interface BodyMeasurementFormValues {
  member_id: number;
  recorded_date: string;
  weight_kg?: number;
  height_cm?: number;
  body_fat_percent?: number;
  chest_cm?: number;
  waist_cm?: number;
  arms_cm?: number;
  thigh_cm?: number;
  hips_cm?: number;
}

export function useCreateBodyMeasurement() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: BodyMeasurementFormValues) => {
      const { data } = await apiClient.post<ApiResponse<BodyMeasurement>>(
        "/body-measurements",
        values,
      );
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: (_, variables) => {
      void queryClient.invalidateQueries({ queryKey: ["body-measurements", variables.member_id] });
    },
  });
}

export function useProgressPhotos(memberId: number) {
  return useQuery({
    queryKey: ["progress-photos", memberId],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<ProgressPhoto[]>>("/progress-photos", {
        params: { member_id: memberId },
      });
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    enabled: !!memberId,
  });
}

export function useUploadProgressPhoto() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (input: {
      member_id: number;
      taken_on: string;
      type?: string;
      notes?: string;
      photo: File;
    }) => {
      const formData = new FormData();
      formData.append("member_id", String(input.member_id));
      formData.append("taken_on", input.taken_on);
      if (input.type) formData.append("type", input.type);
      if (input.notes) formData.append("notes", input.notes);
      formData.append("photo", input.photo);

      const { data } = await apiClient.post<ApiResponse<ProgressPhoto>>(
        "/progress-photos",
        formData,
        { headers: { "Content-Type": "multipart/form-data" } },
      );
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: (_, variables) => {
      void queryClient.invalidateQueries({ queryKey: ["progress-photos", variables.member_id] });
    },
  });
}
