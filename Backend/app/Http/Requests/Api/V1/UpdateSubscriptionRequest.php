<?php

declare(strict_types=1);

namespace App\Http\Requests\Api\V1;

use App\Models\Subscription;
use Illuminate\Foundation\Http\FormRequest;

class UpdateSubscriptionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('super_admin');
    }

    public function rules(): array
    {
        return [
            'plan' => ['sometimes', 'string', 'in:starter,professional,enterprise'],
            'start_date' => ['sometimes', 'date'],
            'expiry_date' => ['sometimes', 'date', 'after:start_date'],
            'payment_status' => ['sometimes', 'string', 'in:active,past_due,cancelled'],
            'member_limit' => ['nullable', 'integer', 'min:1'],
        ];
    }

    protected function prepareForValidation(): void
    {
        if ($this->filled('plan') && array_key_exists($this->input('plan'), Subscription::PLAN_LIMITS)) {
            $this->merge([
                'member_limit' => Subscription::PLAN_LIMITS[$this->input('plan')],
            ]);
        }
    }
}
