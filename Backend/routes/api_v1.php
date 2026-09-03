<?php

use App\Http\Controllers\Api\V1\Auth\AuthController;
use App\Http\Controllers\Api\V1\AttendanceController;
use App\Http\Controllers\Api\V1\DashboardController;
use App\Http\Controllers\Api\V1\MemberController;
use App\Http\Controllers\Api\V1\MembershipPlanController;
use App\Http\Controllers\Api\V1\PaymentController;
use Illuminate\Support\Facades\Route;

Route::post('login', [AuthController::class, 'login'])->middleware('throttle:10,1');

Route::middleware('auth:sanctum')->group(function (): void {
    Route::post('logout', [AuthController::class, 'logout']);
    Route::get('me', [AuthController::class, 'me']);

    Route::get('dashboard', [DashboardController::class, 'index']);

    Route::apiResource('members', MemberController::class);
    Route::post('members/{member}/renew', [MemberController::class, 'renew']);
    Route::get('members/{member}/payments', [MemberController::class, 'payments']);

    Route::apiResource('membership-plans', MembershipPlanController::class);

    Route::apiResource('payments', PaymentController::class)->only(['index', 'store', 'show']);

    Route::get('attendance', [AttendanceController::class, 'index']);
    Route::post('attendance', [AttendanceController::class, 'store']);
});
