<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Role;
use App\Models\User;
use App\Services\GymService;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use RuntimeException;

/**
 * Interactive first-run seeder for a live server: reference data plus a
 * real super admin and one vendor (gym + owner login). Credentials are typed
 * at the prompt (passwords hidden) so none live in code or .env.
 *
 *   php artisan db:seed --class=ProductionSeeder --force
 */
class ProductionSeeder extends Seeder
{
    private const MIN_PASSWORD_LENGTH = 8;

    public function run(GymService $gyms): void
    {
        $this->call([RolesSeeder::class, SubscriptionPlansSeeder::class]);

        $this->seedSuperAdmin();

        if ($this->command->confirm('Add a vendor (gym + owner login)?', true)) {
            $this->seedVendor($gyms);
        }
    }

    private function seedSuperAdmin(): void
    {
        $roleId = Role::query()->where('name', Role::SUPER_ADMIN)->value('id');

        if (User::query()->where('role_id', $roleId)->exists()) {
            $this->command->info('Super admin already exists — skipping.');

            return;
        }

        $data = $this->validated([
            'name' => $this->command->ask('Super admin name'),
            'email' => $this->command->ask('Super admin email'),
            'password' => $this->command->secret('Super admin password (min 8 chars)'),
        ], [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:'.self::MIN_PASSWORD_LENGTH],
        ]);

        User::query()->create([
            'role_id' => $roleId,
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'status' => 'active',
        ]);

        $this->command->info("Super admin created: {$data['email']}");
    }

    private function seedVendor(GymService $gyms): void
    {
        $data = $this->validated([
            'name' => $this->command->ask('Gym name'),
            'phone' => $this->command->ask('Gym phone'),
            'address' => $this->command->ask('Gym address'),
            'admin_name' => $this->command->ask('Owner name'),
            'admin_email' => $this->command->ask('Owner email'),
            'admin_password' => $this->command->secret('Owner password (min 8 chars)'),
        ], [
            'name' => ['required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:20'],
            'address' => ['nullable', 'string', 'max:500'],
            'admin_name' => ['required', 'string', 'max:255'],
            'admin_email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'admin_password' => ['required', 'string', 'min:'.self::MIN_PASSWORD_LENGTH],
        ]);

        $gym = $gyms->create([...$data, 'email' => $data['admin_email']]);

        $this->command->info("Vendor created: {$gym->name} — owner login {$data['admin_email']}");
    }

    /** @return array<string, mixed> */
    private function validated(array $input, array $rules): array
    {
        $validator = Validator::make($input, $rules);

        if ($validator->fails()) {
            throw new RuntimeException(implode(' ', $validator->errors()->all()));
        }

        return $validator->validated();
    }
}
