<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Gym;
use App\Models\Role;
use App\Models\User;
use App\Models\UserGymMembership;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class GymService
{
    public function create(array $data): Gym
    {
        return DB::transaction(function () use ($data) {
            $gym = Gym::query()->create([
                'name' => $data['name'],
                'slug' => $this->uniqueSlug($data['name']),
                'email' => $data['email'] ?? null,
                'phone' => $data['phone'] ?? null,
                'address' => $data['address'] ?? null,
                'status' => 'active',
            ]);

            $adminRoleId = Role::query()->where('name', Role::ADMIN)->value('id');

            $admin = User::query()->create([
                'role_id' => $adminRoleId,
                'name' => $data['admin_name'],
                'email' => $data['admin_email'],
                'password' => Hash::make($data['admin_password']),
                'status' => 'active',
            ]);

            UserGymMembership::query()->create([
                'user_id' => $admin->id,
                'gym_id' => $gym->id,
                'role_id' => $adminRoleId,
                'status' => UserGymMembership::STATUS_ACTIVE,
                'joined_at' => now(),
            ]);

            return $gym;
        });
    }

    public function update(Gym $gym, array $data): Gym
    {
        $gym->update(array_filter([
            'name' => $data['name'] ?? null,
            'email' => $data['email'] ?? null,
            'phone' => $data['phone'] ?? null,
            'address' => $data['address'] ?? null,
            'status' => $data['status'] ?? null,
        ], fn ($value) => $value !== null));

        return $gym->fresh();
    }

    private function uniqueSlug(string $name): string
    {
        $base = Str::slug($name);
        $slug = $base;
        $suffix = 1;

        while (Gym::query()->withTrashed()->where('slug', $slug)->exists()) {
            $slug = "{$base}-{$suffix}";
            $suffix++;
        }

        return $slug;
    }
}
