<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    public function test_user_can_login_with_valid_credentials(): void
    {
        $gym = $this->createGym();
        $user = $this->createUser($gym, Role::ADMIN, ['email' => 'admin@test.local']);

        $response = $this->postJson('/api/v1/login', [
            'email' => 'admin@test.local',
            'password' => 'password',
        ]);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.id', $user->id)
            ->assertJsonStructure(['data' => ['token', 'user']]);
    }

    public function test_login_fails_with_invalid_credentials(): void
    {
        $gym = $this->createGym();
        $this->createUser($gym, Role::ADMIN, ['email' => 'admin@test.local']);

        $response = $this->postJson('/api/v1/login', [
            'email' => 'admin@test.local',
            'password' => 'wrong-password',
        ]);

        $response->assertUnprocessable();
    }

    public function test_inactive_user_cannot_login(): void
    {
        $gym = $this->createGym();
        $this->createUser($gym, Role::ADMIN, ['email' => 'inactive@test.local', 'status' => 'inactive']);

        $response = $this->postJson('/api/v1/login', [
            'email' => 'inactive@test.local',
            'password' => 'password',
        ]);

        $response->assertForbidden();
    }

    public function test_authenticated_user_can_fetch_own_profile(): void
    {
        $gym = $this->createGym();
        $user = $this->createUser($gym, Role::ADMIN);

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/v1/me');

        $response->assertOk()->assertJsonPath('data.id', $user->id);
    }

    public function test_unauthenticated_request_is_rejected(): void
    {
        $response = $this->getJson('/api/v1/me');

        $response->assertUnauthorized();
    }
}
