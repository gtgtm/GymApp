<?php

declare(strict_types=1);

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class StoreDietPlanRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('admin', 'trainer');
    }

    public function rules(): array
    {
        return [
            'member_id' => ['required', 'exists:members,id'],
            'trainer_id' => ['nullable', 'exists:trainers,id'],
            'name' => ['required', 'string', 'max:255'],
            'notes' => ['nullable', 'string'],
            'status' => ['nullable', 'string', 'in:active,inactive'],
            'meals' => ['required', 'array', 'min:1'],
            'meals.*.meal_slot' => [
                'required',
                'string',
                'in:breakfast,mid_morning,lunch,evening_snack,dinner,before_bed',
            ],
            'meals.*.food_item' => ['required', 'string', 'max:255'],
            'meals.*.quantity' => ['nullable', 'string', 'max:100'],
            'meals.*.calories' => ['nullable', 'numeric', 'min:0'],
            'meals.*.protein_g' => ['nullable', 'numeric', 'min:0'],
            'meals.*.carbs_g' => ['nullable', 'numeric', 'min:0'],
            'meals.*.fat_g' => ['nullable', 'numeric', 'min:0'],
            'meals.*.notes' => ['nullable', 'string'],
        ];
    }
}
