import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse, Member } from "@/lib/api-types";

interface MembersQueryParams {
  search?: string;
  status?: string;
  page?: number;
}

export function useMembers(params: MembersQueryParams = {}) {
  return useQuery({
    queryKey: ["members", params],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<Member[]>>("/members", { params });
      if (!data.success) throw new Error(data.error.message);
      return data;
    },
  });
}

export function useMember(id: number | null) {
  return useQuery({
    queryKey: ["members", id],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<Member>>(`/members/${id}`);
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    enabled: id !== null,
  });
}

export interface MemberFormValues {
  full_name: string;
  mobile: string;
  email?: string;
  date_of_birth?: string;
  gender?: string;
  address?: string;
  emergency_contact_name?: string;
  emergency_contact_phone?: string;
  joining_date: string;
  trainer_id?: number;
  height_cm?: number;
  weight_kg?: number;
  blood_group?: string;
  notes?: string;
}

export function useCreateMember() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: MemberFormValues) => {
      const { data } = await apiClient.post<ApiResponse<Member>>("/members", values);
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["members"] });
      void queryClient.invalidateQueries({ queryKey: ["dashboard"] });
    },
  });
}

export function useUpdateMember(id: number) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: Partial<MemberFormValues>) => {
      const { data } = await apiClient.put<ApiResponse<Member>>(`/members/${id}`, values);
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["members"] });
    },
  });
}

interface RenewMembershipInput {
  membership_plan_id: number;
  discount?: number;
  tax?: number;
  amount_paid: number;
  payment_method: string;
}

export function useRenewMembership(memberId: number) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values: RenewMembershipInput) => {
      const { data } = await apiClient.post<ApiResponse<unknown>>(
        `/members/${memberId}/renew`,
        values,
      );
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["members"] });
      void queryClient.invalidateQueries({ queryKey: ["dashboard"] });
      void queryClient.invalidateQueries({ queryKey: ["payments"] });
    },
  });
}
