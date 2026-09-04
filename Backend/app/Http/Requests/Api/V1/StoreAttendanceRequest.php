<?php

declare(strict_types=1);

namespace App\Http\Requests\Api\V1;

use App\Models\Member;
use App\Rules\ExistsInCurrentGym;
use Illuminate\Foundation\Http\FormRequest;

class StoreAttendanceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('admin', 'receptionist', 'trainer');
    }

    public function rules(): array
    {
        return [
            'member_id' => ['required', new ExistsInCurrentGym(Member::class)],
            'status' => ['nullable', 'string', 'in:present,absent,late,leave'],
            'marked_via' => ['nullable', 'string', 'in:manual,qr,search'],
        ];
    }
}
