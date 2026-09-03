<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreEquipmentRequest;
use App\Http\Requests\Api\V1\UpdateEquipmentRequest;
use App\Models\Equipment;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Carbon;

class EquipmentController extends Controller
{
    public function index(): JsonResponse
    {
        return $this->success(Equipment::query()->orderBy('name')->get());
    }

    public function store(StoreEquipmentRequest $request): JsonResponse
    {
        $equipment = Equipment::query()->create($request->validated());

        return $this->success($equipment, status: 201);
    }

    public function show(Equipment $equipment): JsonResponse
    {
        return $this->success($equipment);
    }

    public function update(UpdateEquipmentRequest $request, Equipment $equipment): JsonResponse
    {
        $equipment->update($request->validated());

        return $this->success($equipment);
    }

    public function destroy(Equipment $equipment): JsonResponse
    {
        $equipment->delete();

        return $this->success(['message' => 'Equipment deleted.']);
    }

    public function maintenanceDue(): JsonResponse
    {
        $equipment = Equipment::query()
            ->whereNotNull('next_maintenance_date')
            ->where('next_maintenance_date', '<=', Carbon::today()->addDays(7))
            ->orderBy('next_maintenance_date')
            ->get();

        return $this->success($equipment);
    }
}
