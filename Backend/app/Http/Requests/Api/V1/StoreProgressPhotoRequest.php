<?php

declare(strict_types=1);

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class StoreProgressPhotoRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('admin', 'trainer');
    }

    public function rules(): array
    {
        return [
            'member_id' => ['required', 'exists:members,id'],
            'photo' => ['required', 'image', 'mimes:jpg,jpeg,png,webp', 'max:5120'],
            'type' => ['nullable', 'string', 'in:before,after,progress'],
            'taken_on' => ['required', 'date'],
            'notes' => ['nullable', 'string'],
        ];
    }
}
