<?php

declare(strict_types=1);

namespace App\Http\Requests\Api\V1;

use App\Models\Member;
use App\Rules\ExistsInCurrentGym;
use Illuminate\Foundation\Http\FormRequest;

class StoreBodyMeasurementRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('admin', 'trainer');
    }

    public function rules(): array
    {
        return [
            'member_id' => ['required', new ExistsInCurrentGym(Member::class)],
            'recorded_date' => ['required', 'date'],
            'weight_kg' => ['nullable', 'numeric', 'min:0'],
            'height_cm' => ['nullable', 'numeric', 'min:0'],
            'body_fat_percent' => ['nullable', 'numeric', 'min:0', 'max:100'],
            'chest_cm' => ['nullable', 'numeric', 'min:0'],
            'waist_cm' => ['nullable', 'numeric', 'min:0'],
            'arms_cm' => ['nullable', 'numeric', 'min:0'],
            'thigh_cm' => ['nullable', 'numeric', 'min:0'],
            'hips_cm' => ['nullable', 'numeric', 'min:0'],
        ];
    }
}
