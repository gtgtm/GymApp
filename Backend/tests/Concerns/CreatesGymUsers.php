<?php

declare(strict_types=1);

namespace Tests\Concerns;

use App\Models\Gym;
use App\Models\Role;
use App\Models\User;
use App\Models\UserGymMembership;
use Illuminate\Support\Facades\Hash;

trait CreatesGymUsers
{
    protected function createGym(string $name = 'Test Gym'): Gym
    {
        return Gym::query()->create([
            'name' => $name,
            'slug' => str($name)->slug(),
            'status' => 'active',
        ]);
    }

    protected function createRole(string $name): Role
    {
        return Role::query()->firstOrCreate(['name' => $name], ['label' => ucfirst($name)]);
    }

    protected function createUser(Gym $gym, string $roleName = Role::ADMIN, array $overrides = []): User
    {
        $role = $this->createRole($roleName);

        $user = User::query()->create([
            'gym_id' => $gym->id,
            'role_id' => $role->id,
            'name' => $overrides['name'] ?? ucfirst($roleName).' User',
            'email' => $overrides['email'] ?? strtolower($roleName).'-'.uniqid().'@test.local',
            'password' => Hash::make('password'),
            'status' => 'active',
            ...$overrides,
        ]);

        // super_admin has no gym-scoped membership; every other role needs
        // one for ResolveActingGym to resolve tenancy (see AuthTest,
        // ActingGymTest and friends, which rely on this fixture).
        if ($roleName !== Role::SUPER_ADMIN) {
            UserGymMembership::query()->create([
                'user_id' => $user->id,
                'gym_id' => $gym->id,
                'role_id' => $role->id,
                'status' => UserGymMembership::STATUS_ACTIVE,
                'joined_at' => now(),
            ]);
        }

        return $user;
    }
}
