<?php

declare(strict_types=1);

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class StoreWorkoutPlanRequest extends FormRequest
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
            'exercises' => ['required', 'array', 'min:1'],
            'exercises.*.day_number' => ['required', 'integer', 'min:1', 'max:14'],
            'exercises.*.day_label' => ['nullable', 'string', 'max:255'],
            'exercises.*.exercise_name' => ['required', 'string', 'max:255'],
            'exercises.*.muscle_group' => ['nullable', 'string', 'max:255'],
            'exercises.*.sets' => ['nullable', 'integer', 'min:0'],
            'exercises.*.reps' => ['nullable', 'string', 'max:50'],
            'exercises.*.weight_kg' => ['nullable', 'numeric', 'min:0'],
            'exercises.*.rest_seconds' => ['nullable', 'integer', 'min:0'],
            'exercises.*.instructions' => ['nullable', 'string'],
            'exercises.*.video_url' => ['nullable', 'url', 'max:2048'],
            'exercises.*.trainer_notes' => ['nullable', 'string'],
        ];
    }
}
