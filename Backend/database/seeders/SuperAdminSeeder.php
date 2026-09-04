<?php

namespace Database\Seeders;

use App\Models\Role;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class SuperAdminSeeder extends Seeder
{
    public function run(): void
    {
        $superAdminRoleId = Role::query()->where('name', Role::SUPER_ADMIN)->value('id');

        User::query()->updateOrCreate(
            ['email' => 'superadmin@gymapp.test'],
            [
                'gym_id' => null,
                'role_id' => $superAdminRoleId,
                'name' => 'Platform Owner',
                'password' => Hash::make('password'),
                'status' => 'active',
            ],
        );
    }
}
