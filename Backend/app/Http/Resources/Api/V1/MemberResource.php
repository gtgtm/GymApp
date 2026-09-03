<?php

declare(strict_types=1);

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MemberResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $currentMembership = $this->currentMembership();

        return [
            'id' => $this->id,
            'member_code' => $this->member_code,
            'photo_path' => $this->photo_path,
            'full_name' => $this->full_name,
            'mobile' => $this->mobile,
            'email' => $this->email,
            'date_of_birth' => $this->date_of_birth?->toDateString(),
            'gender' => $this->gender,
            'address' => $this->address,
            'emergency_contact_name' => $this->emergency_contact_name,
            'emergency_contact_phone' => $this->emergency_contact_phone,
            'joining_date' => $this->joining_date?->toDateString(),
            'trainer' => $this->whenLoaded('trainer', fn () => [
                'id' => $this->trainer->id,
                'name' => $this->trainer->name,
            ]),
            'height_cm' => $this->height_cm,
            'weight_kg' => $this->weight_kg,
            'blood_group' => $this->blood_group,
            'notes' => $this->notes,
            'status' => $this->status,
            'expiry_bucket' => $this->expiryBucket(),
            'current_membership' => $currentMembership ? [
                'plan_id' => $currentMembership->membership_plan_id,
                'start_date' => $currentMembership->start_date->toDateString(),
                'end_date' => $currentMembership->end_date->toDateString(),
                'status' => $currentMembership->status,
            ] : null,
            'created_at' => $this->created_at,
        ];
    }
}
