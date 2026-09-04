<?php

namespace Database\Seeders;

use App\Models\BodyMeasurement;
use App\Models\DietPlan;
use App\Models\Enquiry;
use App\Models\Equipment;
use App\Models\Expense;
use App\Models\Gym;
use App\Models\Member;
use App\Models\Membership;
use App\Models\MembershipPlan;
use App\Models\Role;
use App\Models\Subscription;
use App\Models\Trainer;
use App\Models\Trial;
use App\Models\User;
use App\Models\WorkoutPlan;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;

class DemoGymSeeder extends Seeder
{
    public function run(): void
    {
        $gym = Gym::query()->updateOrCreate(
            ['slug' => 'demo-fitness-club'],
            [
                'name' => 'Demo Fitness Club',
                'email' => 'owner@demofitness.test',
                'phone' => '9999900000',
                'address' => '123 Fitness Street, Mumbai',
                'status' => 'active',
            ],
        );

        Subscription::query()->updateOrCreate(
            ['gym_id' => $gym->id, 'plan' => Subscription::PLAN_PROFESSIONAL],
            [
                'member_limit' => Subscription::PLAN_LIMITS[Subscription::PLAN_PROFESSIONAL],
                'start_date' => Carbon::today()->subMonths(2),
                'expiry_date' => Carbon::today()->addYear(),
                'payment_status' => Subscription::STATUS_ACTIVE,
            ],
        );

        $roles = Role::query()->pluck('id', 'name');

        $admin = User::query()->updateOrCreate(
            ['email' => 'admin@demofitness.test'],
            [
                'gym_id' => $gym->id,
                'role_id' => $roles[Role::ADMIN],
                'name' => 'Aarav Sharma',
                'phone' => '9999900001',
                'password' => Hash::make('password'),
                'status' => 'active',
            ],
        );

        $receptionist = User::query()->updateOrCreate(
            ['email' => 'reception@demofitness.test'],
            [
                'gym_id' => $gym->id,
                'role_id' => $roles[Role::RECEPTIONIST],
                'name' => 'Priya Nair',
                'phone' => '9999900002',
                'password' => Hash::make('password'),
                'status' => 'active',
            ],
        );

        $trainer = User::query()->updateOrCreate(
            ['email' => 'trainer@demofitness.test'],
            [
                'gym_id' => $gym->id,
                'role_id' => $roles[Role::TRAINER],
                'name' => 'Rohan Verma',
                'phone' => '9999900003',
                'password' => Hash::make('password'),
                'status' => 'active',
            ],
        );

        auth()->login($admin);

        $trainerProfile = Trainer::query()->updateOrCreate(
            ['user_id' => $trainer->id],
            [
                'gym_id' => $gym->id,
                'specialization' => 'Strength & Conditioning',
                'joining_date' => Carbon::today()->subYear(),
                'salary' => 35000,
                'status' => 'active',
            ],
        );

        $monthlyPlan = MembershipPlan::query()->updateOrCreate(
            ['gym_id' => $gym->id, 'name' => 'Monthly'],
            [
                'duration_days' => 30,
                'price' => 1500,
                'registration_fee' => 200,
                'discount' => 0,
                'tax' => 0,
                'total_amount' => 1700,
                'description' => 'Full gym access billed monthly.',
                'benefits' => ['Gym access', 'Locker'],
                'freeze_days' => 3,
                'status' => 'active',
            ],
        );

        $quarterlyPlan = MembershipPlan::query()->updateOrCreate(
            ['gym_id' => $gym->id, 'name' => 'Quarterly'],
            [
                'duration_days' => 90,
                'price' => 4000,
                'registration_fee' => 200,
                'discount' => 200,
                'tax' => 0,
                'total_amount' => 4000,
                'description' => 'Full gym access billed every 3 months.',
                'benefits' => ['Gym access', 'Locker', '1 free PT session'],
                'freeze_days' => 7,
                'status' => 'active',
            ],
        );

        $yearlyPlan = MembershipPlan::query()->updateOrCreate(
            ['gym_id' => $gym->id, 'name' => 'Yearly'],
            [
                'duration_days' => 365,
                'price' => 14000,
                'registration_fee' => 0,
                'discount' => 1000,
                'tax' => 0,
                'total_amount' => 13000,
                'description' => 'Best value annual membership.',
                'benefits' => ['Gym access', 'Locker', 'Diet plan', '4 free PT sessions'],
                'freeze_days' => 15,
                'status' => 'active',
            ],
        );

        $today = Carbon::today();

        $membersData = [
            ['name' => 'Vikas Kumar', 'mobile' => '9800000001', 'plan' => $monthlyPlan, 'end_in_days' => 25],
            ['name' => 'Anita Rao', 'mobile' => '9800000002', 'plan' => $quarterlyPlan, 'end_in_days' => 10],
            ['name' => 'Suresh Iyer', 'mobile' => '9800000003', 'plan' => $monthlyPlan, 'end_in_days' => 3],
            ['name' => 'Meena Joshi', 'mobile' => '9800000004', 'plan' => $yearlyPlan, 'end_in_days' => -5],
            ['name' => 'Rahul Singh', 'mobile' => '9800000005', 'plan' => $monthlyPlan, 'end_in_days' => 20],
        ];

        $firstMember = null;
        $memberRoleId = $roles[Role::MEMBER];

        foreach ($membersData as $index => $data) {
            $memberUser = null;

            if ($index === 0) {
                $memberUser = User::query()->updateOrCreate(
                    ['email' => 'member@demofitness.test'],
                    [
                        'gym_id' => $gym->id,
                        'role_id' => $memberRoleId,
                        'name' => $data['name'],
                        'phone' => $data['mobile'],
                        'password' => Hash::make('password'),
                        'status' => 'active',
                    ],
                );
            }

            $member = Member::query()->updateOrCreate(
                ['gym_id' => $gym->id, 'mobile' => $data['mobile']],
                [
                    'user_id' => $memberUser?->id,
                    'qr_token' => 'DEMO-QR-'.($index + 1),
                    'member_code' => 'MEM-DEMO'.($index + 1),
                    'full_name' => $data['name'],
                    'joining_date' => $today->copy()->subDays(60),
                    'trainer_id' => $trainer->id,
                    'height_cm' => 170,
                    'weight_kg' => 75,
                    'blood_group' => 'O+',
                    'status' => 'active',
                ],
            );

            Membership::query()->updateOrCreate(
                ['member_id' => $member->id, 'membership_plan_id' => $data['plan']->id],
                [
                    'gym_id' => $gym->id,
                    'start_date' => $today->copy()->subDays(30 - $data['end_in_days']),
                    'end_date' => $today->copy()->addDays($data['end_in_days']),
                    'status' => 'active',
                ],
            );

            $firstMember ??= $member;
        }

        $workoutPlan = WorkoutPlan::query()->updateOrCreate(
            ['gym_id' => $gym->id, 'member_id' => $firstMember->id, 'name' => 'Beginner Strength Split'],
            ['trainer_id' => $trainerProfile->id, 'status' => 'active'],
        );
        $workoutPlan->exercises()->delete();
        $workoutPlan->exercises()->createMany([
            ['gym_id' => $gym->id, 'day_number' => 1, 'day_label' => 'Chest & Triceps', 'exercise_name' => 'Bench Press', 'muscle_group' => 'Chest', 'sets' => 4, 'reps' => '8-10', 'weight_kg' => 40, 'rest_seconds' => 90, 'sort_order' => 0],
            ['gym_id' => $gym->id, 'day_number' => 1, 'day_label' => 'Chest & Triceps', 'exercise_name' => 'Tricep Pushdown', 'muscle_group' => 'Triceps', 'sets' => 3, 'reps' => '12', 'weight_kg' => 15, 'rest_seconds' => 60, 'sort_order' => 1],
            ['gym_id' => $gym->id, 'day_number' => 2, 'day_label' => 'Back & Biceps', 'exercise_name' => 'Lat Pulldown', 'muscle_group' => 'Back', 'sets' => 4, 'reps' => '10', 'weight_kg' => 35, 'rest_seconds' => 90, 'sort_order' => 0],
            ['gym_id' => $gym->id, 'day_number' => 3, 'day_label' => 'Legs & Shoulders', 'exercise_name' => 'Squat', 'muscle_group' => 'Legs', 'sets' => 4, 'reps' => '8', 'weight_kg' => 50, 'rest_seconds' => 120, 'sort_order' => 0],
        ]);

        $dietPlan = DietPlan::query()->updateOrCreate(
            ['gym_id' => $gym->id, 'member_id' => $firstMember->id, 'name' => 'Standard Cutting Plan'],
            ['trainer_id' => $trainerProfile->id, 'status' => 'active'],
        );
        $dietPlan->meals()->delete();
        $dietPlan->meals()->createMany([
            ['gym_id' => $gym->id, 'meal_slot' => 'breakfast', 'food_item' => 'Oats with whey', 'quantity' => '1 bowl', 'calories' => 350, 'protein_g' => 30, 'carbs_g' => 40, 'fat_g' => 8, 'sort_order' => 0],
            ['gym_id' => $gym->id, 'meal_slot' => 'lunch', 'food_item' => 'Grilled chicken with rice', 'quantity' => '250g', 'calories' => 550, 'protein_g' => 45, 'carbs_g' => 60, 'fat_g' => 12, 'sort_order' => 1],
            ['gym_id' => $gym->id, 'meal_slot' => 'dinner', 'food_item' => 'Paneer salad', 'quantity' => '200g', 'calories' => 400, 'protein_g' => 28, 'carbs_g' => 20, 'fat_g' => 20, 'sort_order' => 2],
        ]);

        BodyMeasurement::query()->updateOrCreate(
            ['gym_id' => $gym->id, 'member_id' => $firstMember->id, 'recorded_date' => $today->copy()->subDays(60)],
            ['weight_kg' => 82, 'height_cm' => 170, 'bmi' => round(82 / (1.70 ** 2), 2), 'recorded_by' => $trainer->id],
        );
        BodyMeasurement::query()->updateOrCreate(
            ['gym_id' => $gym->id, 'member_id' => $firstMember->id, 'recorded_date' => $today->copy()->subDays(30)],
            ['weight_kg' => 79, 'height_cm' => 170, 'bmi' => round(79 / (1.70 ** 2), 2), 'recorded_by' => $trainer->id],
        );
        BodyMeasurement::query()->updateOrCreate(
            ['gym_id' => $gym->id, 'member_id' => $firstMember->id, 'recorded_date' => $today],
            ['weight_kg' => 76, 'height_cm' => 170, 'bmi' => round(76 / (1.70 ** 2), 2), 'recorded_by' => $trainer->id],
        );

        $enquiriesData = [
            ['name' => 'Karan Mehta', 'mobile' => '9700000001', 'source' => 'Walk-in', 'status' => Enquiry::STATUS_NEW, 'plan' => $monthlyPlan, 'follow_up_in_days' => 2],
            ['name' => 'Divya Kapoor', 'mobile' => '9700000002', 'source' => 'Instagram', 'status' => Enquiry::STATUS_CONTACTED, 'plan' => $quarterlyPlan, 'follow_up_in_days' => 1],
            ['name' => 'Sameer Khan', 'mobile' => '9700000003', 'source' => 'Referral', 'status' => Enquiry::STATUS_TRIAL, 'plan' => $monthlyPlan, 'follow_up_in_days' => 0],
            ['name' => 'Neha Bhatt', 'mobile' => '9700000004', 'source' => 'Google', 'status' => Enquiry::STATUS_CONVERTED, 'plan' => $yearlyPlan, 'follow_up_in_days' => null],
            ['name' => 'Arjun Desai', 'mobile' => '9700000005', 'source' => 'Walk-in', 'status' => Enquiry::STATUS_LOST, 'plan' => $monthlyPlan, 'follow_up_in_days' => null],
        ];

        $trialEnquiry = null;

        foreach ($enquiriesData as $data) {
            $enquiry = Enquiry::query()->updateOrCreate(
                ['gym_id' => $gym->id, 'mobile' => $data['mobile']],
                [
                    'name' => $data['name'],
                    'source' => $data['source'],
                    'interested_plan_id' => $data['plan']->id,
                    'follow_up_date' => $data['follow_up_in_days'] !== null ? $today->copy()->addDays($data['follow_up_in_days']) : null,
                    'assigned_staff_id' => $receptionist->id,
                    'status' => $data['status'],
                ],
            );

            if ($data['status'] === Enquiry::STATUS_TRIAL) {
                $trialEnquiry = $enquiry;
            }
        }

        Trial::query()->updateOrCreate(
            ['gym_id' => $gym->id, 'mobile' => $trialEnquiry->mobile],
            [
                'enquiry_id' => $trialEnquiry->id,
                'name' => $trialEnquiry->name,
                'trial_start' => $today->copy()->subDays(2),
                'trial_end' => $today->copy()->addDay(),
                'trainer_id' => $trainerProfile->id,
                'status' => Trial::STATUS_ACTIVE,
            ],
        );

        $expensesData = [
            ['category' => Expense::CATEGORY_RENT, 'amount' => 45000, 'days_ago' => 5, 'description' => 'Monthly gym floor rent'],
            ['category' => Expense::CATEGORY_ELECTRICITY, 'amount' => 8500, 'days_ago' => 4, 'description' => 'Electricity bill'],
            ['category' => Expense::CATEGORY_SALARY, 'amount' => 35000, 'days_ago' => 3, 'description' => 'Trainer salary'],
            ['category' => Expense::CATEGORY_MAINTENANCE, 'amount' => 3200, 'days_ago' => 2, 'description' => 'Treadmill servicing'],
            ['category' => Expense::CATEGORY_MARKETING, 'amount' => 2000, 'days_ago' => 1, 'description' => 'Instagram ads'],
        ];

        foreach ($expensesData as $data) {
            Expense::query()->updateOrCreate(
                ['gym_id' => $gym->id, 'category' => $data['category'], 'expense_date' => $today->copy()->subDays($data['days_ago'])],
                [
                    'amount' => $data['amount'],
                    'description' => $data['description'],
                    'payment_method' => 'bank_transfer',
                    'recorded_by' => $admin->id,
                ],
            );
        }

        $equipmentData = [
            ['name' => 'Treadmill #1', 'category' => 'Cardio', 'purchase_days_ago' => 400, 'price' => 85000, 'condition' => Equipment::CONDITION_GOOD, 'next_maintenance_in_days' => 20],
            ['name' => 'Leg Press Machine', 'category' => 'Strength', 'purchase_days_ago' => 600, 'price' => 65000, 'condition' => Equipment::CONDITION_FAIR, 'next_maintenance_in_days' => 5],
            ['name' => 'Dumbbell Set (5-50kg)', 'category' => 'Free Weights', 'purchase_days_ago' => 200, 'price' => 45000, 'condition' => Equipment::CONDITION_GOOD, 'next_maintenance_in_days' => 90],
            ['name' => 'Rowing Machine', 'category' => 'Cardio', 'purchase_days_ago' => 800, 'price' => 55000, 'condition' => Equipment::CONDITION_NEEDS_REPAIR, 'next_maintenance_in_days' => -2],
        ];

        foreach ($equipmentData as $data) {
            Equipment::query()->updateOrCreate(
                ['gym_id' => $gym->id, 'name' => $data['name']],
                [
                    'category' => $data['category'],
                    'purchase_date' => $today->copy()->subDays($data['purchase_days_ago']),
                    'purchase_price' => $data['price'],
                    'condition' => $data['condition'],
                    'last_maintenance_date' => $today->copy()->subDays(90),
                    'next_maintenance_date' => $today->copy()->addDays($data['next_maintenance_in_days']),
                ],
            );
        }

        auth()->logout();
    }
}
