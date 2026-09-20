<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\SubscriptionPlan;
use Illuminate\Database\Seeder;

class SubscriptionPlansSeeder extends Seeder
{
    public function run(): void
    {
        collect([
            ['name' => 'Starter', 'slug' => 'starter', 'member_limit' => 300, 'sort_order' => 1],
            ['name' => 'Professional', 'slug' => 'professional', 'member_limit' => 1000, 'sort_order' => 2],
            ['name' => 'Enterprise', 'slug' => 'enterprise', 'member_limit' => null, 'sort_order' => 3],
        ])->each(fn (array $plan) => SubscriptionPlan::query()->updateOrCreate(
            ['slug' => $plan['slug']],
            [...$plan, 'status' => 'active'],
        ));
    }
}
