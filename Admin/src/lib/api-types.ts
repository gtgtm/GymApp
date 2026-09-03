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

export interface Trainer {
  id: number;
  gym_id: number;
  user_id: number;
  specialization: string | null;
  joining_date: string | null;
  salary: string | null;
  status: "active" | "inactive";
  assigned_members_count?: number;
  user: { id: number; name: string; email: string; phone: string | null; status: string };
  assigned_members?: Array<{ id: number; full_name: string; member_code: string }>;
}

export type MealSlot =
  | "breakfast"
  | "mid_morning"
  | "lunch"
  | "evening_snack"
  | "dinner"
  | "before_bed";

export interface WorkoutExercise {
  id?: number;
  day_number: number;
  day_label: string | null;
  exercise_name: string;
  muscle_group: string | null;
  sets: number | null;
  reps: string | null;
  weight_kg: string | null;
  rest_seconds: number | null;
  instructions: string | null;
  video_url: string | null;
  trainer_notes: string | null;
}

export interface WorkoutPlan {
  id: number;
  member_id: number;
  trainer_id: number | null;
  name: string;
  notes: string | null;
  status: "active" | "inactive";
  exercises: WorkoutExercise[];
  trainer?: { id: number; user: { id: number; name: string } } | null;
}

export interface DietMeal {
  id?: number;
  meal_slot: MealSlot;
  food_item: string;
  quantity: string | null;
  calories: string | null;
  protein_g: string | null;
  carbs_g: string | null;
  fat_g: string | null;
  notes: string | null;
}

export interface DietPlan {
  id: number;
  member_id: number;
  trainer_id: number | null;
  name: string;
  notes: string | null;
  status: "active" | "inactive";
  meals: DietMeal[];
  daily_summary: {
    calories: number;
    protein_g: number;
    carbs_g: number;
    fat_g: number;
  };
}

export interface BodyMeasurement {
  id: number;
  member_id: number;
  recorded_date: string;
  weight_kg: string | null;
  height_cm: string | null;
  bmi: string | null;
  body_fat_percent: string | null;
  chest_cm: string | null;
  waist_cm: string | null;
  arms_cm: string | null;
  thigh_cm: string | null;
  hips_cm: string | null;
}

export interface ProgressPhoto {
  id: number;
  member_id: number;
  url: string;
  type: "before" | "after" | "progress";
  taken_on: string;
  notes: string | null;
}
