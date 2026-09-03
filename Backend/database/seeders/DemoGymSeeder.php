<?php

namespace Database\Seeders;

use App\Models\Gym;
use App\Models\Member;
use App\Models\Membership;
use App\Models\MembershipPlan;
use App\Models\Role;
use App\Models\User;
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

        User::query()->updateOrCreate(
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

        foreach ($membersData as $index => $data) {
            $member = Member::query()->updateOrCreate(
                ['gym_id' => $gym->id, 'mobile' => $data['mobile']],
                [
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
        }

        auth()->logout();
    }
}
