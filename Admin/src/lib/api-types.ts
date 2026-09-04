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
  monthly_expenses: number;
  monthly_net_profit: number;
  new_enquiries: number;
  active_trainers: number;
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

export type EnquiryStatus = "new" | "contacted" | "trial" | "follow_up" | "converted" | "lost";

export interface Enquiry {
  id: number;
  name: string;
  mobile: string;
  email: string | null;
  source: string | null;
  interested_plan_id: number | null;
  interested_plan?: { id: number; name: string } | null;
  follow_up_date: string | null;
  assigned_staff_id: number | null;
  assigned_staff?: { id: number; name: string } | null;
  status: EnquiryStatus;
  notes: string | null;
  created_at: string;
}

export interface ConversionStats {
  total: number;
  converted: number;
  conversion_rate: number;
  by_status: Record<string, number>;
}

export type TrialStatus = "active" | "expired" | "converted";

export interface Trial {
  id: number;
  enquiry_id: number | null;
  name: string;
  mobile: string;
  trial_start: string;
  trial_end: string;
  trainer_id: number | null;
  trainer?: { id: number; user: { id: number; name: string } } | null;
  status: TrialStatus;
}

export type ExpenseCategory =
  | "rent"
  | "electricity"
  | "equipment"
  | "maintenance"
  | "salary"
  | "marketing"
  | "cleaning"
  | "other";

export interface Expense {
  id: number;
  category: ExpenseCategory;
  amount: string;
  expense_date: string;
  description: string | null;
  payment_method: string | null;
}

export type EquipmentCondition = "good" | "fair" | "needs_repair" | "out_of_service";

export interface Equipment {
  id: number;
  name: string;
  category: string | null;
  purchase_date: string | null;
  purchase_price: string | null;
  warranty_expiry: string | null;
  condition: EquipmentCondition;
  last_maintenance_date: string | null;
  next_maintenance_date: string | null;
}

export interface GymNotification {
  id: number;
  type: string;
  title: string;
  body: string | null;
  data: Record<string, unknown> | null;
  channel: string;
  read_at: string | null;
  created_at: string;
}

export interface AiSuggestion {
  category: string;
  message: string;
  action_label: string;
  action_route: string;
  severity: "info" | "warning" | "success" | "danger";
}

export interface FinancialReport {
  summary: {
    from: string;
    to: string;
    revenue: number;
    expenses: number;
    profit: number;
    payment_method_breakdown: Record<string, string>;
    expense_category_breakdown: Record<string, string>;
  };
  daily_revenue: Array<{ date: string; total: number }>;
}

export interface MembersReport {
  summary: {
    from: string;
    to: string;
    new_members: number;
    active_members: number;
    expired_members: number;
    renewals: number;
    churn_rate: number;
  };
  plan_distribution: Array<{ plan_name: string; count: number }>;
}

export interface AttendanceReport {
  daily: Array<{ date: string; count: number }>;
  by_day_of_week: Array<{ day: string; count: number }>;
  member_wise: Array<{ member: string; member_code: string; visits: number }>;
}

export interface TrainerReportRow {
  trainer: string;
  assigned_members: number;
  workout_plans_created: number;
  diet_plans_created: number;
}

export interface SalesReport {
  summary: {
    from: string;
    to: string;
    leads: number;
    converted_leads: number;
    conversion_rate: number;
    trials: number;
    trials_converted: number;
    trial_conversion_rate: number;
  };
  revenue_by_plan: Array<{ plan: string; sold_count: number; estimated_revenue: number }>;
}

export interface GlobalSearchResults {
  members: Array<{ id: number; full_name: string; mobile: string; member_code: string }>;
  trainers: Array<{ id: number; user: { id: number; name: string; phone: string | null } }>;
  payments: Array<{ id: number; receipt_number: string; amount: string; member_id: number }>;
  enquiries: Array<{ id: number; name: string; mobile: string; status: string }>;
}

export type SubscriptionPlan = "starter" | "professional" | "enterprise";

export interface Subscription {
  id: number;
  gym_id: number;
  gym?: { id: number; name: string };
  plan: SubscriptionPlan;
  member_limit: number | null;
  start_date: string;
  expiry_date: string;
  payment_status: "active" | "past_due" | "cancelled";
}
