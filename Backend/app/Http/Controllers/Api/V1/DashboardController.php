<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\DashboardService;
use Illuminate\Http\JsonResponse;

class DashboardController extends Controller
{
    public function __construct(private readonly DashboardService $dashboardService) {}

    public function index(): JsonResponse
    {
        return $this->success([
            'summary' => $this->dashboardService->summary(),
            'expiring' => $this->dashboardService->expiryBuckets(),
        ]);
    }
}
