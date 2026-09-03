<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\BodyMeasurement;

class BodyMeasurementService
{
    public function create(array $data): BodyMeasurement
    {
        return BodyMeasurement::query()->create([
            ...$data,
            'bmi' => $this->calculateBmi($data['weight_kg'] ?? null, $data['height_cm'] ?? null),
            'recorded_by' => auth()->id(),
        ]);
    }

    private function calculateBmi(?float $weightKg, ?float $heightCm): ?float
    {
        if (! $weightKg || ! $heightCm) {
            return null;
        }

        $heightMeters = $heightCm / 100;

        return round($weightKg / ($heightMeters ** 2), 2);
    }
}
