<?php

namespace Database\Seeders;

use App\Models\Attendance;
use App\Models\AuditLog;
use App\Models\BodyMeasurement;
use App\Models\DietMeal;
use App\Models\DietPlan;
use App\Models\Enquiry;
use App\Models\Equipment;
use App\Models\Expense;
use App\Models\Gym;
use App\Models\GymNotification;
use App\Models\Invoice;
use App\Models\Member;
use App\Models\Membership;
use App\Models\MembershipPlan;
use App\Models\MembershipRenewal;
use App\Models\Payment;
use App\Models\ProgressPhoto;
use App\Models\Role;
use App\Models\Subscription;
use App\Models\Trainer;
use App\Models\Trial;
use App\Models\User;
use App\Models\WorkoutExercise;
use App\Models\WorkoutPlan;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;

class TenRecordsSeeder extends Seeder
{
    public function run(): void
    {
        $gym = Gym::query()->where('slug', 'demo-fitness-club')->firstOrFail();
        $today = Carbon::today();
        $roles = Role::query()->pluck('id', 'name');

        $admin = User::query()->where('gym_id', $gym->id)->where('role_id', $roles[Role::ADMIN])->firstOrFail();
        $receptionist = User::query()->where('gym_id', $gym->id)->where('role_id', $roles[Role::RECEPTIONIST])->firstOrFail();
        $trainerUser = User::query()->where('gym_id', $gym->id)->where('role_id', $roles[Role::TRAINER])->firstOrFail();
        $trainerProfile = Trainer::query()->where('user_id', $trainerUser->id)->firstOrFail();

        // --- Top up other gyms to 10 (isolated tenants, no cross-links to demo data) ---
        $existingGyms = Gym::query()->count();
        for ($i = $existingGyms; $i < 10; $i++) {
            Gym::query()->updateOrCreate(
                ['slug' => 'demo-gym-'.($i + 1)],
                [
                    'name' => 'Demo Gym '.($i + 1),
                    'email' => 'owner'.($i + 1).'@demofitness.test',
                    'phone' => '99999100'.str_pad((string) ($i + 1), 2, '0', STR_PAD_LEFT),
                    'address' => ($i + 1).' Fitness Avenue',
                    'status' => 'active',
                ],
            );
        }

        // --- Top up membership plans to 10 for the demo gym ---
        $planPool = [
            ['name' => 'Half-Yearly', 'duration_days' => 180, 'price' => 8000, 'total_amount' => 8000],
            ['name' => 'Weekly Trial', 'duration_days' => 7, 'price' => 500, 'total_amount' => 500],
            ['name' => 'Couple Monthly', 'duration_days' => 30, 'price' => 2500, 'total_amount' => 2500],
            ['name' => 'Student Monthly', 'duration_days' => 30, 'price' => 1200, 'total_amount' => 1200],
            ['name' => 'Premium Yearly', 'duration_days' => 365, 'price' => 20000, 'total_amount' => 20000],
            ['name' => 'Off-Peak Monthly', 'duration_days' => 30, 'price' => 1000, 'total_amount' => 1000],
            ['name' => 'Corporate Quarterly', 'duration_days' => 90, 'price' => 3500, 'total_amount' => 3500],
        ];
        $existingPlanCount = MembershipPlan::query()->where('gym_id', $gym->id)->count();
        foreach ($planPool as $index => $data) {
            if ($existingPlanCount + $index >= 10) {
                break;
            }

            MembershipPlan::query()->updateOrCreate(
                ['gym_id' => $gym->id, 'name' => $data['name']],
                [
                    'duration_days' => $data['duration_days'],
                    'price' => $data['price'],
                    'registration_fee' => 0,
                    'discount' => 0,
                    'tax' => 0,
                    'total_amount' => $data['total_amount'],
                    'description' => $data['name'].' membership plan.',
                    'benefits' => ['Gym access'],
                    'freeze_days' => 5,
                    'status' => 'active',
                ],
            );
        }

        $plans = MembershipPlan::query()->where('gym_id', $gym->id)->orderBy('id')->get();
        $monthlyPlan = $plans->firstWhere('name', 'Monthly');
        $quarterlyPlan = $plans->firstWhere('name', 'Quarterly');
        $yearlyPlan = $plans->firstWhere('name', 'Yearly');
        $planCycle = [$monthlyPlan, $quarterlyPlan, $yearlyPlan];

        // --- Top up trainer users + profiles to 10 ---
        $existingTrainerUsers = User::query()->where('gym_id', $gym->id)->where('role_id', $roles[Role::TRAINER])->count();
        $trainerNamePool = [
            'Rohan Verma', 'Kabir Malhotra', 'Simran Kaur', 'Tarun Gill', 'Aisha Fernandes',
            'Yash Oberoi', 'Ritu Chawla', 'Devansh Kohli', 'Naina Bakshi', 'Omkar Patil',
        ];
        $specializations = ['Strength & Conditioning', 'Yoga', 'Cardio', 'CrossFit', 'Powerlifting', 'Zumba', 'Calisthenics', 'Nutrition Coaching', 'Rehabilitation', 'HIIT'];

        for ($i = $existingTrainerUsers; $i < 10; $i++) {
            $trainerUserExtra = User::query()->updateOrCreate(
                ['email' => 'trainer'.($i + 1).'@demofitness.test'],
                [
                    'gym_id' => $gym->id,
                    'role_id' => $roles[Role::TRAINER],
                    'name' => $trainerNamePool[$i] ?? ('Trainer '.($i + 1)),
                    'phone' => '9999901'.str_pad((string) ($i + 1), 2, '0', STR_PAD_LEFT),
                    'password' => Hash::make('password'),
                    'status' => 'active',
                ],
            );

            Trainer::query()->updateOrCreate(
                ['user_id' => $trainerUserExtra->id],
                [
                    'gym_id' => $gym->id,
                    'specialization' => $specializations[$i % count($specializations)],
                    'joining_date' => $today->copy()->subMonths($i + 1),
                    'salary' => 30000 + ($i * 1000),
                    'status' => 'active',
                ],
            );
        }

        $trainerProfiles = Trainer::query()->where('gym_id', $gym->id)->orderBy('id')->take(10)->get();

        // --- Top up members to 10 ---
        $existingMembers = Member::query()->where('gym_id', $gym->id)->count();
        $namePool = [
            'Vikas Kumar', 'Anita Rao', 'Suresh Iyer', 'Meena Joshi', 'Rahul Singh',
            'Kavita Menon', 'Deepak Chauhan', 'Pooja Reddy', 'Manoj Tiwari', 'Sneha Pillai',
        ];

        for ($i = $existingMembers; $i < 10; $i++) {
            $mobile = '98000000'.str_pad((string) ($i + 1), 2, '0', STR_PAD_LEFT);
            $plan = $planCycle[$i % 3];
            $endInDays = 30 - ($i * 3);

            $member = Member::query()->updateOrCreate(
                ['gym_id' => $gym->id, 'mobile' => $mobile],
                [
                    'qr_token' => 'DEMO-QR-'.($i + 1),
                    'member_code' => 'MEM-DEMO'.($i + 1),
                    'full_name' => $namePool[$i] ?? ('Member '.($i + 1)),
                    'joining_date' => $today->copy()->subDays(60),
                    'trainer_id' => $trainerUser->id,
                    'height_cm' => 165 + $i,
                    'weight_kg' => 70 + $i,
                    'blood_group' => 'O+',
                    'status' => 'active',
                ],
            );

            Membership::query()->updateOrCreate(
                ['member_id' => $member->id, 'membership_plan_id' => $plan->id],
                [
                    'gym_id' => $gym->id,
                    'start_date' => $today->copy()->subDays(30 - $endInDays),
                    'end_date' => $today->copy()->addDays($endInDays),
                    'status' => 'active',
                ],
            );
        }

        $members = Member::query()->where('gym_id', $gym->id)->orderBy('id')->take(10)->get();
        $memberships = Membership::query()->where('gym_id', $gym->id)->orderBy('id')->take(10)->get();

        // --- Top up enquiries to 10 ---
        $existingEnquiries = Enquiry::query()->where('gym_id', $gym->id)->count();
        $enquiryStatuses = [
            Enquiry::STATUS_NEW, Enquiry::STATUS_CONTACTED, Enquiry::STATUS_TRIAL,
            Enquiry::STATUS_FOLLOW_UP, Enquiry::STATUS_CONVERTED, Enquiry::STATUS_LOST,
        ];
        $enquiryNamePool = [
            'Karan Mehta', 'Divya Kapoor', 'Sameer Khan', 'Neha Bhatt', 'Arjun Desai',
            'Ishaan Malhotra', 'Ritika Sen', 'Aditya Pandey', 'Farah Sheikh', 'Nikhil Bose',
        ];

        for ($i = $existingEnquiries; $i < 10; $i++) {
            $mobile = '97000000'.str_pad((string) ($i + 1), 2, '0', STR_PAD_LEFT);
            $status = $enquiryStatuses[$i % count($enquiryStatuses)];
            $plan = $planCycle[$i % 3];

            Enquiry::query()->updateOrCreate(
                ['gym_id' => $gym->id, 'mobile' => $mobile],
                [
                    'name' => $enquiryNamePool[$i] ?? ('Lead '.($i + 1)),
                    'source' => ['Walk-in', 'Instagram', 'Referral', 'Google'][$i % 4],
                    'interested_plan_id' => $plan->id,
                    'follow_up_date' => $status === Enquiry::STATUS_CONVERTED || $status === Enquiry::STATUS_LOST
                        ? null
                        : $today->copy()->addDays($i % 5),
                    'assigned_staff_id' => $receptionist->id,
                    'status' => $status,
                ],
            );
        }

        $enquiries = Enquiry::query()->where('gym_id', $gym->id)->orderBy('id')->take(10)->get();

        // --- Trials (10) ---
        $existingTrials = Trial::query()->where('gym_id', $gym->id)->count();
        $trialCandidates = $enquiries->filter(fn ($e) => in_array($e->status, [Enquiry::STATUS_TRIAL, Enquiry::STATUS_FOLLOW_UP, Enquiry::STATUS_CONVERTED, Enquiry::STATUS_NEW, Enquiry::STATUS_CONTACTED], true))->values();

        for ($i = $existingTrials; $i < 10; $i++) {
            $enquiry = $trialCandidates[$i % $trialCandidates->count()];
            $mobile = '96000000'.str_pad((string) ($i + 1), 2, '0', STR_PAD_LEFT);

            Trial::query()->updateOrCreate(
                ['gym_id' => $gym->id, 'mobile' => $mobile],
                [
                    'enquiry_id' => $enquiry->id,
                    'name' => $enquiry->name,
                    'trial_start' => $today->copy()->subDays(5 - ($i % 5)),
                    'trial_end' => $today->copy()->addDays($i % 3),
                    'trainer_id' => $trainerProfile->id,
                    'status' => [Trial::STATUS_ACTIVE, Trial::STATUS_EXPIRED, Trial::STATUS_CONVERTED][$i % 3],
                ],
            );
        }

        // --- Top up expenses to 10 ---
        $existingExpenses = Expense::query()->where('gym_id', $gym->id)->count();
        $expenseCategories = [
            Expense::CATEGORY_RENT, Expense::CATEGORY_ELECTRICITY, Expense::CATEGORY_SALARY,
            Expense::CATEGORY_MAINTENANCE, Expense::CATEGORY_MARKETING, Expense::CATEGORY_EQUIPMENT,
            Expense::CATEGORY_CLEANING, Expense::CATEGORY_OTHER,
        ];

        for ($i = $existingExpenses; $i < 10; $i++) {
            $category = $expenseCategories[$i % count($expenseCategories)];

            Expense::query()->updateOrCreate(
                ['gym_id' => $gym->id, 'category' => $category, 'expense_date' => $today->copy()->subDays($i + 1)],
                [
                    'amount' => 1500 + ($i * 500),
                    'description' => ucfirst($category).' expense #'.($i + 1),
                    'payment_method' => $i % 2 === 0 ? 'bank_transfer' : 'cash',
                    'recorded_by' => $admin->id,
                ],
            );
        }

        // --- Top up equipment to 10 ---
        $existingEquipment = Equipment::query()->where('gym_id', $gym->id)->count();
        $equipmentPool = [
            ['name' => 'Treadmill #2', 'category' => 'Cardio', 'condition' => Equipment::CONDITION_GOOD],
            ['name' => 'Elliptical Trainer', 'category' => 'Cardio', 'condition' => Equipment::CONDITION_GOOD],
            ['name' => 'Cable Crossover Machine', 'category' => 'Strength', 'condition' => Equipment::CONDITION_FAIR],
            ['name' => 'Smith Machine', 'category' => 'Strength', 'condition' => Equipment::CONDITION_GOOD],
            ['name' => 'Kettlebell Set', 'category' => 'Free Weights', 'condition' => Equipment::CONDITION_GOOD],
            ['name' => 'Barbell Rack', 'category' => 'Free Weights', 'condition' => Equipment::CONDITION_FAIR],
        ];

        for ($i = $existingEquipment; $i < 10; $i++) {
            $data = $equipmentPool[($i - $existingEquipment) % count($equipmentPool)];

            Equipment::query()->updateOrCreate(
                ['gym_id' => $gym->id, 'name' => $data['name']],
                [
                    'category' => $data['category'],
                    'purchase_date' => $today->copy()->subDays(300 + $i * 10),
                    'purchase_price' => 30000 + ($i * 5000),
                    'condition' => $data['condition'],
                    'last_maintenance_date' => $today->copy()->subDays(60),
                    'next_maintenance_date' => $today->copy()->addDays(30 + $i),
                ],
            );
        }

        // --- Invoices (10) ---
        $invoiceCount = Invoice::query()->where('gym_id', $gym->id)->count();
        $invoices = collect();

        for ($i = $invoiceCount; $i < 10; $i++) {
            $member = $members[$i % $members->count()];
            $plan = $planCycle[$i % 3];

            $invoice = Invoice::query()->updateOrCreate(
                ['gym_id' => $gym->id, 'invoice_number' => 'INV-DEMO-'.str_pad((string) ($i + 1), 4, '0', STR_PAD_LEFT)],
                [
                    'member_id' => $member->id,
                    'line_items' => [
                        ['label' => $plan->name.' Membership', 'amount' => (float) $plan->total_amount],
                    ],
                    'total' => $plan->total_amount,
                    'status' => $i % 4 === 0 ? 'unpaid' : 'paid',
                ],
            );

            $invoices->push($invoice);
        }

        $invoices = $invoices->count() > 0
            ? $invoices
            : Invoice::query()->where('gym_id', $gym->id)->orderBy('id')->take(10)->get();

        // --- Payments (10) ---
        $paymentCount = Payment::query()->where('gym_id', $gym->id)->count();
        $allInvoices = Invoice::query()->where('gym_id', $gym->id)->orderBy('id')->take(10)->get();

        for ($i = $paymentCount; $i < 10; $i++) {
            $member = $members[$i % $members->count()];
            $invoice = $allInvoices[$i % max($allInvoices->count(), 1)] ?? null;

            Payment::query()->updateOrCreate(
                ['gym_id' => $gym->id, 'receipt_number' => 'RCPT-DEMO-'.str_pad((string) ($i + 1), 4, '0', STR_PAD_LEFT)],
                [
                    'member_id' => $member->id,
                    'invoice_id' => $invoice?->id,
                    'amount' => 1500 + ($i * 200),
                    'discount' => $i % 3 === 0 ? 100 : 0,
                    'tax' => 0,
                    'method' => ['cash', 'card', 'upi', 'bank_transfer'][$i % 4],
                    'status' => 'completed',
                    'paid_at' => $today->copy()->subDays($i),
                    'collected_by' => $receptionist->id,
                ],
            );
        }

        // --- Membership Renewals (10) ---
        $renewalCount = MembershipRenewal::query()->where('gym_id', $gym->id)->count();

        for ($i = $renewalCount; $i < 10; $i++) {
            $membership = $memberships[$i % $memberships->count()];
            $plan = $planCycle[$i % 3];

            MembershipRenewal::query()->create([
                'gym_id' => $gym->id,
                'membership_id' => $membership->id,
                'membership_plan_id' => $plan->id,
                'previous_expiry' => $today->copy()->subDays(30 - $i),
                'new_expiry' => $today->copy()->addDays(30 + $i),
                'discount' => 0,
                'tax' => 0,
                'amount_paid' => $plan->total_amount,
                'amount_due' => 0,
                'payment_method' => $i % 2 === 0 ? 'cash' : 'upi',
                'renewed_by' => $receptionist->id,
            ]);
        }

        // --- Attendance (10, one per member per today-offset day) ---
        $attendanceCount = Attendance::query()->where('gym_id', $gym->id)->count();

        for ($i = $attendanceCount; $i < 10; $i++) {
            $member = $members[$i % $members->count()];

            Attendance::query()->updateOrCreate(
                ['member_id' => $member->id, 'date' => $today->copy()->subDays($i)],
                [
                    'gym_id' => $gym->id,
                    'check_in_time' => '0'.(6 + $i % 3).':30:00',
                    'status' => 'present',
                    'marked_via' => $i % 2 === 0 ? 'qr' : 'manual',
                    'marked_by' => $receptionist->id,
                ],
            );
        }

        // --- Progress Photos (10) ---
        $photoCount = ProgressPhoto::query()->where('gym_id', $gym->id)->count();

        for ($i = $photoCount; $i < 10; $i++) {
            $member = $members[$i % $members->count()];

            ProgressPhoto::query()->create([
                'gym_id' => $gym->id,
                'member_id' => $member->id,
                'photo_path' => 'demo/progress-photos/member-'.$member->id.'-'.($i + 1).'.jpg',
                'type' => $i % 2 === 0 ? 'progress' : 'before_after',
                'taken_on' => $today->copy()->subDays($i * 7),
                'notes' => 'Progress check-in #'.($i + 1),
                'uploaded_by' => $trainerUser->id,
            ]);
        }

        // --- Notifications (10) ---
        $notificationCount = GymNotification::query()->where('gym_id', $gym->id)->count();
        $notificationTypes = [
            GymNotification::TYPE_MEMBERSHIP_EXPIRING, GymNotification::TYPE_PAYMENT_RECEIPT,
            GymNotification::TYPE_RENEWAL_CONFIRMATION, GymNotification::TYPE_NEW_WORKOUT_PLAN,
            GymNotification::TYPE_NEW_DIET_PLAN, GymNotification::TYPE_PENDING_PAYMENT,
            GymNotification::TYPE_NEW_ENQUIRY, GymNotification::TYPE_TRIAL_EXPIRING,
            GymNotification::TYPE_EQUIPMENT_MAINTENANCE, GymNotification::TYPE_RENEWAL_REQUESTED,
        ];

        for ($i = $notificationCount; $i < 10; $i++) {
            $type = $notificationTypes[$i % count($notificationTypes)];
            $member = $members[$i % $members->count()];

            GymNotification::query()->create([
                'gym_id' => $gym->id,
                'user_id' => $member->user_id ?? $admin->id,
                'type' => $type,
                'title' => str_replace('_', ' ', ucfirst($type)),
                'body' => 'Demo notification for '.$type,
                'data' => ['member_id' => $member->id],
                'channel' => GymNotification::CHANNEL_IN_APP,
                'read_at' => $i % 3 === 0 ? $today->copy()->subDay() : null,
                'sent_at' => $today->copy()->subHours($i),
            ]);
        }

        // --- Workout Plans + Exercises (10 plans, one per member) ---
        $existingWorkoutPlans = WorkoutPlan::query()->where('gym_id', $gym->id)->count();

        for ($i = $existingWorkoutPlans; $i < 10; $i++) {
            $member = $members[$i % $members->count()];
            $trainerProfile = $trainerProfiles[$i % $trainerProfiles->count()];

            $workoutPlan = WorkoutPlan::query()->updateOrCreate(
                ['gym_id' => $gym->id, 'member_id' => $member->id, 'name' => 'Plan #'.($i + 1).' - '.$member->full_name],
                ['trainer_id' => $trainerProfile->id, 'status' => 'active'],
            );

            WorkoutExercise::query()->updateOrCreate(
                ['gym_id' => $gym->id, 'workout_plan_id' => $workoutPlan->id, 'day_number' => 1, 'sort_order' => 0],
                [
                    'day_label' => 'Full Body',
                    'exercise_name' => 'Compound Lift #'.($i + 1),
                    'muscle_group' => 'Full Body',
                    'sets' => 3 + ($i % 3),
                    'reps' => '8-12',
                    'weight_kg' => 20 + $i,
                    'rest_seconds' => 60,
                    'sort_order' => 0,
                ],
            );
        }

        // --- Diet Plans + Meals (10 plans, one per member) ---
        $existingDietPlans = DietPlan::query()->where('gym_id', $gym->id)->count();

        for ($i = $existingDietPlans; $i < 10; $i++) {
            $member = $members[$i % $members->count()];
            $trainerProfile = $trainerProfiles[$i % $trainerProfiles->count()];

            $dietPlan = DietPlan::query()->updateOrCreate(
                ['gym_id' => $gym->id, 'member_id' => $member->id, 'name' => 'Diet #'.($i + 1).' - '.$member->full_name],
                ['trainer_id' => $trainerProfile->id, 'status' => 'active'],
            );

            DietMeal::query()->updateOrCreate(
                ['gym_id' => $gym->id, 'diet_plan_id' => $dietPlan->id, 'meal_slot' => 'breakfast', 'sort_order' => 0],
                [
                    'food_item' => 'Oats with fruit',
                    'quantity' => '1 bowl',
                    'calories' => 300 + ($i * 10),
                    'protein_g' => 20,
                    'carbs_g' => 40,
                    'fat_g' => 8,
                    'sort_order' => 0,
                ],
            );
        }

        // --- Body Measurements (10, one per member) ---
        $existingMeasurements = BodyMeasurement::query()->where('gym_id', $gym->id)->count();

        for ($i = $existingMeasurements; $i < 10; $i++) {
            $member = $members[$i % $members->count()];
            $weight = 70 + $i;
            $height = 1.65 + ($i * 0.01);

            BodyMeasurement::query()->updateOrCreate(
                ['gym_id' => $gym->id, 'member_id' => $member->id, 'recorded_date' => $today->copy()->subDays($i * 15)],
                [
                    'weight_kg' => $weight,
                    'height_cm' => $height * 100,
                    'bmi' => round($weight / ($height ** 2), 2),
                    'recorded_by' => $trainerUser->id,
                ],
            );
        }

        // --- Subscriptions (10, one per top-up gym) ---
        $existingSubscriptions = Subscription::query()->count();
        $subscriptionPlans = [Subscription::PLAN_STARTER, Subscription::PLAN_PROFESSIONAL, Subscription::PLAN_ENTERPRISE];
        $allGyms = Gym::query()->orderBy('id')->take(10)->get();

        for ($i = $existingSubscriptions; $i < 10; $i++) {
            $targetGym = $allGyms[$i % $allGyms->count()];
            $plan = $subscriptionPlans[$i % count($subscriptionPlans)];

            Subscription::query()->updateOrCreate(
                ['gym_id' => $targetGym->id, 'plan' => $plan],
                [
                    'member_limit' => Subscription::PLAN_LIMITS[$plan],
                    'start_date' => $today->copy()->subMonths($i + 1),
                    'expiry_date' => $today->copy()->addMonths(12 - $i % 12),
                    'payment_status' => Subscription::STATUS_ACTIVE,
                ],
            );
        }

        // --- Audit Logs (10) ---
        $actions = ['created', 'updated', 'deleted', 'status_changed'];
        $entityTypes = ['Member', 'Membership', 'Payment', 'Expense', 'Equipment'];

        for ($i = 0; $i < 10; $i++) {
            AuditLog::query()->updateOrCreate(
                ['gym_id' => $gym->id, 'entity_type' => $entityTypes[$i % count($entityTypes)], 'entity_id' => $i + 1],
                [
                    'user_id' => $admin->id,
                    'action' => $actions[$i % count($actions)],
                    'before' => null,
                    'after' => ['note' => 'demo audit entry #'.($i + 1)],
                    'ip_address' => '127.0.0.1',
                ],
            );
        }
    }
}
