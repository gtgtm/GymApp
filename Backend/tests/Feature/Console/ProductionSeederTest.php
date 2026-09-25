<?php

declare(strict_types=1);

namespace Tests\Feature\Console;

use App\Models\Gym;
use App\Models\Role;
use App\Models\User;
use App\Models\UserGymMembership;
use Database\Seeders\ProductionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class ProductionSeederTest extends TestCase
{
    use RefreshDatabase;

    public function test_creates_super_admin_and_vendor_gym_with_owner(): void
    {
        $this->runSeeder(withSuperAdmin: true)->assertExitCode(0);

        $superAdmin = User::query()->where('email', 'owner@platform.in')->firstOrFail();
        $this->assertSame(Role::SUPER_ADMIN, $superAdmin->role->name);
        $this->assertTrue(Hash::check('SuperSecret1', $superAdmin->password));

        $gym = Gym::query()->where('name', 'Power House Gym')->firstOrFail();
        $this->assertSame('9876543210', $gym->phone);

        $vendor = User::query()->where('email', 'vendor@powerhouse.in')->firstOrFail();
        $this->assertSame(Role::ADMIN, $vendor->role->name);
        $this->assertTrue(Hash::check('VendorSecret1', $vendor->password));
        $this->assertTrue(UserGymMembership::query()
            ->where(['user_id' => $vendor->id, 'gym_id' => $gym->id])->exists());
    }

    public function test_skips_super_admin_when_one_already_exists(): void
    {
        $this->runSeeder(withSuperAdmin: true);

        $this->artisan('db:seed', ['--class' => ProductionSeeder::class, '--force' => true])
            ->expectsConfirmation('Add a vendor (gym + owner login)?', 'no')
            ->assertExitCode(0);

        $this->assertSame(1, User::query()->whereRelation('role', 'name', Role::SUPER_ADMIN)->count());
    }

    public function test_rejects_short_password_without_creating_user(): void
    {
        try {
            $this->artisan('db:seed', ['--class' => ProductionSeeder::class, '--force' => true])
                ->expectsQuestion('Super admin name', 'Platform Owner')
                ->expectsQuestion('Super admin email', 'owner@platform.in')
                ->expectsQuestion('Super admin password (min 8 chars)', 'short')
                ->run();
            $this->fail('Expected the seeder to reject a short password.');
        } catch (\RuntimeException $exception) {
            $this->assertStringContainsString('at least 8 characters', $exception->getMessage());
        }

        $this->assertDatabaseMissing('users', ['email' => 'owner@platform.in']);
    }

    private function runSeeder(bool $withSuperAdmin): \Illuminate\Testing\PendingCommand
    {
        $command = $this->artisan('db:seed', ['--class' => ProductionSeeder::class, '--force' => true]);

        if ($withSuperAdmin) {
            $command
                ->expectsQuestion('Super admin name', 'Platform Owner')
                ->expectsQuestion('Super admin email', 'owner@platform.in')
                ->expectsQuestion('Super admin password (min 8 chars)', 'SuperSecret1');
        }

        return $command
            ->expectsConfirmation('Add a vendor (gym + owner login)?', 'yes')
            ->expectsQuestion('Gym name', 'Power House Gym')
            ->expectsQuestion('Gym phone', '9876543210')
            ->expectsQuestion('Gym address', 'MG Road, Indore')
            ->expectsQuestion('Owner name', 'Rahul Mehta')
            ->expectsQuestion('Owner email', 'vendor@powerhouse.in')
            ->expectsQuestion('Owner password (min 8 chars)', 'VendorSecret1');
    }
}
