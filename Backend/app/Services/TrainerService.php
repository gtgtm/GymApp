<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Role;
use App\Models\Trainer;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class TrainerService
{
    public function create(array $data): Trainer
    {
        return DB::transaction(function () use ($data) {
            $gymId = auth()->user()->gym_id;
            $trainerRoleId = Role::query()->where('name', Role::TRAINER)->value('id');

            $user = User::query()->create([
                'gym_id' => $gymId,
                'role_id' => $trainerRoleId,
                'name' => $data['name'],
                'email' => $data['email'],
                'phone' => $data['phone'] ?? null,
                'password' => Hash::make($data['password']),
                'status' => 'active',
            ]);

            return Trainer::query()->create([
                'gym_id' => $gymId,
                'user_id' => $user->id,
                'specialization' => $data['specialization'] ?? null,
                'joining_date' => $data['joining_date'] ?? null,
                'salary' => $data['salary'] ?? null,
                'status' => $data['status'] ?? 'active',
            ]);
        });
    }

    public function update(Trainer $trainer, array $data): Trainer
    {
        return DB::transaction(function () use ($trainer, $data) {
            $trainer->update(array_filter([
                'specialization' => $data['specialization'] ?? null,
                'joining_date' => $data['joining_date'] ?? null,
                'salary' => $data['salary'] ?? null,
                'status' => $data['status'] ?? null,
            ], fn ($value) => $value !== null));

            if (isset($data['name']) || isset($data['phone'])) {
                $trainer->user->update(array_filter([
                    'name' => $data['name'] ?? null,
                    'phone' => $data['phone'] ?? null,
                ], fn ($value) => $value !== null));
            }

            return $trainer->fresh('user');
        });
    }
}
