<?php

use App\Http\Controllers\Api\V1\Auth\AuthController;
use App\Http\Controllers\Api\V1\AiSuggestionController;
use App\Http\Controllers\Api\V1\AttendanceController;
use App\Http\Controllers\Api\V1\BodyMeasurementController;
use App\Http\Controllers\Api\V1\DashboardController;
use App\Http\Controllers\Api\V1\DietPlanController;
use App\Http\Controllers\Api\V1\EnquiryController;
use App\Http\Controllers\Api\V1\EquipmentController;
use App\Http\Controllers\Api\V1\ExpenseController;
use App\Http\Controllers\Api\V1\MemberController;
use App\Http\Controllers\Api\V1\MembershipPlanController;
use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\PaymentController;
use App\Http\Controllers\Api\V1\ProgressPhotoController;
use App\Http\Controllers\Api\V1\ReportController;
use App\Http\Controllers\Api\V1\TrainerController;
use App\Http\Controllers\Api\V1\TrialController;
use App\Http\Controllers\Api\V1\WorkoutPlanController;
use Illuminate\Support\Facades\Route;

Route::post('login', [AuthController::class, 'login'])->middleware('throttle:10,1');

Route::middleware('auth:sanctum')->group(function (): void {
    Route::post('logout', [AuthController::class, 'logout']);
    Route::get('me', [AuthController::class, 'me']);

    Route::get('dashboard', [DashboardController::class, 'index']);

    Route::get('notifications', [NotificationController::class, 'index']);
    Route::put('notifications/{notification}/read', [NotificationController::class, 'markRead']);
    Route::post('notifications/mark-all-read', [NotificationController::class, 'markAllRead']);

    // Staff-only surface: admin, receptionist, trainer. Member-portal scoping
    // (a member seeing only their own records) is introduced in a later phase
    // alongside the mobile app, when the `member` role actually logs in here.
    Route::middleware('role:admin,receptionist,trainer')->group(function (): void {
        Route::apiResource('members', MemberController::class);
        Route::post('members/{member}/renew', [MemberController::class, 'renew']);
        Route::get('members/{member}/payments', [MemberController::class, 'payments']);

        Route::apiResource('membership-plans', MembershipPlanController::class)->only(['index', 'show']);

        Route::apiResource('payments', PaymentController::class)->only(['index', 'store', 'show']);

        Route::get('attendance', [AttendanceController::class, 'index']);
        Route::post('attendance', [AttendanceController::class, 'store']);

        Route::apiResource('trainers', TrainerController::class)->only(['index', 'show']);

        Route::apiResource('workout-plans', WorkoutPlanController::class);

        Route::apiResource('diet-plans', DietPlanController::class);

        Route::get('body-measurements', [BodyMeasurementController::class, 'index']);
        Route::post('body-measurements', [BodyMeasurementController::class, 'store']);

        Route::get('progress-photos', [ProgressPhotoController::class, 'index']);
        Route::post('progress-photos', [ProgressPhotoController::class, 'store']);
        Route::delete('progress-photos/{progressPhoto}', [ProgressPhotoController::class, 'destroy']);
    });

    Route::middleware('role:admin,receptionist')->group(function (): void {
        Route::apiResource('enquiries', EnquiryController::class);
        Route::get('enquiries-stats/conversion', [EnquiryController::class, 'conversionStats']);

        Route::apiResource('trials', TrialController::class);
        Route::get('trials-expiring-soon', [TrialController::class, 'expiringSoon']);

        Route::get('ai/suggestions', [AiSuggestionController::class, 'index']);
    });

    Route::middleware('role:admin')->group(function (): void {
        Route::apiResource('membership-plans', MembershipPlanController::class)->only([
            'store', 'update', 'destroy',
        ]);

        Route::apiResource('trainers', TrainerController::class)->only([
            'store', 'update', 'destroy',
        ]);

        Route::apiResource('expenses', ExpenseController::class);

        Route::apiResource('equipment', EquipmentController::class);
        Route::get('equipment-maintenance-due', [EquipmentController::class, 'maintenanceDue']);

        Route::prefix('reports')->group(function (): void {
            Route::get('financial', [ReportController::class, 'financial']);
            Route::get('financial/export/csv', [ReportController::class, 'financialExportCsv']);
            Route::get('financial/export/pdf', [ReportController::class, 'financialExportPdf']);

            Route::get('members', [ReportController::class, 'members']);
            Route::get('members/export/csv', [ReportController::class, 'membersExportCsv']);

            Route::get('attendance', [ReportController::class, 'attendance']);
            Route::get('attendance/export/csv', [ReportController::class, 'attendanceExportCsv']);

            Route::get('trainers', [ReportController::class, 'trainers']);
            Route::get('trainers/export/csv', [ReportController::class, 'trainersExportCsv']);

            Route::get('sales', [ReportController::class, 'sales']);
            Route::get('sales/export/csv', [ReportController::class, 'salesExportCsv']);
        });
    });
});
