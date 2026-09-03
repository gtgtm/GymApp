<?php

namespace Database\Seeders;

use App\Models\Role;
use Illuminate\Database\Seeder;

class RolesSeeder extends Seeder
{
    public function run(): void
    {
        collect([
            ['name' => Role::ADMIN, 'label' => 'Admin / Gym Owner'],
            ['name' => Role::RECEPTIONIST, 'label' => 'Receptionist'],
            ['name' => Role::TRAINER, 'label' => 'Trainer'],
            ['name' => Role::MEMBER, 'label' => 'Member'],
        ])->each(fn (array $role) => Role::query()->updateOrCreate(['name' => $role['name']], $role));
    }
}
