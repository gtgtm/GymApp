<?php

declare(strict_types=1);

namespace App\Http\Requests\Api\V1;

use App\Models\MembershipPlan;
use App\Rules\ExistsInCurrentGym;
use Illuminate\Foundation\Http\FormRequest;

class RenewMembershipRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('admin', 'receptionist');
    }

    public function rules(): array
    {
        return [
            'membership_plan_id' => ['required', new ExistsInCurrentGym(MembershipPlan::class)],
            'discount' => ['nullable', 'numeric', 'min:0'],
            'tax' => ['nullable', 'numeric', 'min:0'],
            'amount_paid' => ['required', 'numeric', 'min:0'],
            'payment_method' => ['required', 'string', 'in:cash,upi,card,bank_transfer,online'],
        ];
    }
}
