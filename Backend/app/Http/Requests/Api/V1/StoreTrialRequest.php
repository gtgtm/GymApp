<?php

declare(strict_types=1);

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class StoreTrialRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('admin', 'receptionist');
    }

    public function rules(): array
    {
        return [
            'enquiry_id' => ['nullable', 'exists:enquiries,id'],
            'name' => ['required', 'string', 'max:255'],
            'mobile' => ['required', 'string', 'max:20'],
            'trial_start' => ['required', 'date'],
            'trial_end' => ['required', 'date', 'after_or_equal:trial_start'],
            'trainer_id' => ['nullable', 'exists:trainers,id'],
            'status' => ['nullable', 'string', 'in:active,expired,converted'],
        ];
    }
}
