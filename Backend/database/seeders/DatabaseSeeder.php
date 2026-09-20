<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            RolesSeeder::class,
            SubscriptionPlansSeeder::class,
            DemoGymSeeder::class,
            MultiGymDemoSeeder::class,
            SuperAdminSeeder::class,
            TenRecordsSeeder::class,
        ]);
    }
}
