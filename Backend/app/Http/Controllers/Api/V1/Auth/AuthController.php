<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\User;
use App\Services\AuditLogService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function __construct(private readonly AuditLogService $auditLog) {}

    public function login(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        if ($validator->fails()) {
            return $this->fail('Validation failed.', 422, $validator->errors());
        }

        $credentials = $validator->validated();

        if (! Auth::attempt($credentials)) {
            $this->logFailedAttempt($credentials['email']);

            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        /** @var User $user */
        $user = Auth::user();

        if ($user->status !== 'active') {
            Auth::logout();

            $this->logFailedAttempt($credentials['email'], $user);

            return $this->fail('This account is inactive.', 403);
        }

        $token = $user->createToken('api-token')->plainTextToken;

        $this->auditLog->log('login', $user);

        return $this->success([
            'token' => $token,
            'user' => $user->load('role', 'gym'),
        ]);
    }

    private function logFailedAttempt(string $email, ?User $user = null): void
    {
        $user ??= User::query()->where('email', $email)->first();

        AuditLog::query()->create([
            'gym_id' => $user?->gym_id,
            'user_id' => $user?->id,
            'action' => 'login_failed',
            'entity_type' => User::class,
            'entity_id' => $user?->id,
            'before' => null,
            'after' => ['email' => $email],
            'ip_address' => request()->ip(),
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        $this->auditLog->log('logout', $request->user());

        return $this->success(['message' => 'Logged out successfully.']);
    }

    public function me(Request $request): JsonResponse
    {
        return $this->success($request->user()->load('role', 'gym'));
    }
}
