<?php

declare(strict_types=1);

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class ProgressPhotoResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'member_id' => $this->member_id,
            'url' => Storage::disk('public')->url($this->photo_path),
            'type' => $this->type,
            'taken_on' => $this->taken_on->toDateString(),
            'notes' => $this->notes,
            'created_at' => $this->created_at,
        ];
    }
}
