<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\ProgressPhoto;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

class ProgressPhotoService
{
    public function create(array $data, UploadedFile $photo): ProgressPhoto
    {
        $path = $photo->store('progress-photos/'.$data['member_id'], 'public');

        return ProgressPhoto::query()->create([
            'member_id' => $data['member_id'],
            'photo_path' => $path,
            'type' => $data['type'] ?? ProgressPhoto::TYPE_PROGRESS,
            'taken_on' => $data['taken_on'],
            'notes' => $data['notes'] ?? null,
            'uploaded_by' => auth()->id(),
        ]);
    }

    public function delete(ProgressPhoto $photo): void
    {
        Storage::disk('public')->delete($photo->photo_path);
        $photo->delete();
    }
}
