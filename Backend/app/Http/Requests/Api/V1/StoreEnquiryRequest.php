<?php

declare(strict_types=1);

namespace App\Http\Requests\Api\V1;

use App\Models\MembershipPlan;
use App\Models\User;
use App\Rules\ExistsInCurrentGym;
use Illuminate\Foundation\Http\FormRequest;

class StoreEnquiryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('admin', 'receptionist');
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'mobile' => ['required', 'string', 'max:20'],
            'email' => ['nullable', 'email', 'max:255'],
            'source' => ['nullable', 'string', 'max:255'],
            'interested_plan_id' => ['nullable', new ExistsInCurrentGym(MembershipPlan::class)],
            'follow_up_date' => ['nullable', 'date'],
            'assigned_staff_id' => ['nullable', new ExistsInCurrentGym(User::class, 'gym_id')],
            'status' => ['nullable', 'string', 'in:new,contacted,trial,follow_up,converted,lost'],
            'notes' => ['nullable', 'string'],
        ];
    }
}
