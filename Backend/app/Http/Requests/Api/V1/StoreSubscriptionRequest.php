<?php

declare(strict_types=1);

namespace App\Http\Requests\Api\V1;

use App\Models\Subscription;
use Illuminate\Foundation\Http\FormRequest;

class StoreSubscriptionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('super_admin');
    }

    public function rules(): array
    {
        return [
            // Intentionally the plain `exists` rule, not ExistsInCurrentGym:
            // Gym is the tenant root (no GymScope of its own) and this
            // endpoint is super_admin-only, who must be able to reference
            // any gym on the platform.
            'gym_id' => ['required', 'exists:gyms,id'],
            'plan' => ['required', 'string', 'in:starter,professional,enterprise'],
            'start_date' => ['required', 'date'],
            'expiry_date' => ['required', 'date', 'after:start_date'],
            'payment_status' => ['nullable', 'string', 'in:active,past_due,cancelled'],
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
