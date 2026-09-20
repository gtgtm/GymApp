<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Gym;
use App\Models\Role;
use App\Models\Subscription;
use App\Models\User;
use App\Models\UserGymMembership;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;

/**
 * Proves multi-gym identity end to end: the demo member
 * (member@demofitness.test) is ALSO a trainer at a second gym, under the
 * same login. This is the fixture every "does X-Gym-Id actually isolate
 * two memberships for one person" test should exercise.
 */
class MultiGymDemoSeeder extends Seeder
{
    public function run(): void
    {
        $secondGym = Gym::query()->updateOrCreate(
            ['slug' => 'iron-paradise'],
            [
                'name' => 'Iron Paradise',
                'email' => 'owner@ironparadise.test',
                'phone' => '9999900099',
                'address' => '77 Strength Lane, Pune',
                'status' => 'active',
            ],
        );

        Subscription::query()->updateOrCreate(
            ['gym_id' => $secondGym->id, 'plan' => Subscription::PLAN_STARTER],
            [
                'member_limit' => Subscription::PLAN_LIMITS[Subscription::PLAN_STARTER],
                'start_date' => Carbon::today()->subMonth(),
                'expiry_date' => Carbon::today()->addYear(),
                'payment_status' => Subscription::STATUS_ACTIVE,
            ],
        );

        $roles = Role::query()->pluck('id', 'name');

        $sharedUser = User::query()->where('email', 'member@demofitness.test')->first();

        if (! $sharedUser) {
            // DemoGymSeeder hasn't run yet in this call order; nothing to link.
            return;
        }

        UserGymMembership::query()->updateOrCreate(
            ['user_id' => $sharedUser->id, 'gym_id' => $secondGym->id],
            [
                'role_id' => $roles[Role::TRAINER],
                'status' => UserGymMembership::STATUS_ACTIVE,
                'joined_at' => Carbon::today()->subMonth(),
            ],
        );

        // A second gym needs its own admin to be usable from the platform
        // owner's "Enter as Admin" flow.
        User::query()->updateOrCreate(
            ['email' => 'admin@ironparadise.test'],
            [
                'role_id' => $roles[Role::ADMIN],
                'name' => 'Iron Paradise Admin',
                'phone' => '9999900098',
                'password' => Hash::make('password'),
                'status' => 'active',
            ],
        );

        $secondGymAdmin = User::query()->where('email', 'admin@ironparadise.test')->firstOrFail();

        UserGymMembership::query()->updateOrCreate(
            ['user_id' => $secondGymAdmin->id, 'gym_id' => $secondGym->id],
            ['role_id' => $roles[Role::ADMIN], 'status' => UserGymMembership::STATUS_ACTIVE, 'joined_at' => Carbon::today()->subMonth()],
        );
    }
}
