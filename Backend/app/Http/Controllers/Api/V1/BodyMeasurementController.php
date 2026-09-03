<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreBodyMeasurementRequest;
use App\Models\BodyMeasurement;
use App\Services\BodyMeasurementService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BodyMeasurementController extends Controller
{
    public function __construct(private readonly BodyMeasurementService $bodyMeasurementService) {}

    public function index(Request $request): JsonResponse
    {
        $measurements = BodyMeasurement::query()
            ->when($request->integer('member_id'), fn ($query, $memberId) => $query->where('member_id', $memberId))
            ->orderBy('recorded_date')
            ->get();

        return $this->success($measurements);
    }

    public function store(StoreBodyMeasurementRequest $request): JsonResponse
    {
        $measurement = $this->bodyMeasurementService->create($request->validated());

        return $this->success($measurement, status: 201);
    }
}
