<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
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
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        /** @var User $user */
        $user = Auth::user();

        if ($user->status !== 'active') {
            Auth::logout();

            return $this->fail('This account is inactive.', 403);
        }

        $token = $user->createToken('api-token')->plainTextToken;

        $this->auditLog->log('login', $user);

        return $this->success([
            'token' => $token,
            'user' => $user->load('role', 'gym'),
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
