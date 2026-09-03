export interface ApiSuccess<T> {
  success: true;
  data: T;
  error: null;
  meta?: {
    total: number;
    page: number;
    limit: number;
  };
}

export interface ApiFailure {
  success: false;
  data: null;
  error: {
    message: string;
    errors?: Record<string, string[]>;
  };
}

export type ApiResponse<T> = ApiSuccess<T> | ApiFailure;

export interface Role {
  id: number;
  name: "admin" | "receptionist" | "trainer" | "member";
  label: string;
}

export interface Gym {
  id: number;
  name: string;
  slug: string;
  email: string | null;
  phone: string | null;
  address: string | null;
  status: string;
}

export interface AuthUser {
  id: number;
  gym_id: number;
  role_id: number;
  name: string;
  email: string;
  phone: string | null;
  status: string;
  role: Role;
  gym: Gym;
}

export type ExpiryBucket = "green" | "yellow" | "orange" | "red";

export interface Member {
  id: number;
  member_code: string;
  photo_path: string | null;
  full_name: string;
  mobile: string;
  email: string | null;
  date_of_birth: string | null;
  gender: string | null;
  address: string | null;
  emergency_contact_name: string | null;
  emergency_contact_phone: string | null;
  joining_date: string;
  trainer: { id: number; name: string } | null;
  height_cm: string | null;
  weight_kg: string | null;
  blood_group: string | null;
  notes: string | null;
  status: string;
  expiry_bucket: ExpiryBucket;
  current_membership: {
    plan_id: number;
    start_date: string;
    end_date: string;
    status: string;
  } | null;
  created_at: string;
}

export interface MembershipPlan {
  id: number;
  gym_id: number;
  name: string;
  duration_days: number;
  price: string;
  registration_fee: string;
  discount: string;
  tax: string;
  total_amount: string;
  description: string | null;
  benefits: string[] | null;
  freeze_days: number;
  status: "active" | "inactive";
}

export interface Payment {
  id: number;
  member_id: number;
  receipt_number: string;
  amount: string;
  discount: string;
  tax: string;
  method: string;
  status: string;
  paid_at: string;
  member?: { id: number; full_name: string; member_code: string };
}

export interface DashboardSummary {
  total_members: number;
  active_members: number;
  expired_memberships: number;
  expiring_soon: number;
  todays_attendance: number;
  todays_new_members: number;
  todays_revenue: number;
  monthly_revenue: number;
  pending_payments: number;
}

export interface DashboardResponse {
  summary: DashboardSummary;
  expiring: Record<ExpiryBucket, Array<{
    id: number;
    end_date: string;
    member: { id: number; full_name: string; mobile: string; member_code: string };
  }>>;
}
