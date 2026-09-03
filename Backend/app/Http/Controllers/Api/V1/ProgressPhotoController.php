<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreProgressPhotoRequest;
use App\Http\Resources\Api\V1\ProgressPhotoResource;
use App\Models\ProgressPhoto;
use App\Services\ProgressPhotoService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProgressPhotoController extends Controller
{
    public function __construct(private readonly ProgressPhotoService $progressPhotoService) {}

    public function index(Request $request): JsonResponse
    {
        $photos = ProgressPhoto::query()
            ->when($request->integer('member_id'), fn ($query, $memberId) => $query->where('member_id', $memberId))
            ->orderBy('taken_on')
            ->get();

        return $this->success(ProgressPhotoResource::collection($photos));
    }

    public function store(StoreProgressPhotoRequest $request): JsonResponse
    {
        $photo = $this->progressPhotoService->create(
            $request->validated(),
            $request->file('photo'),
        );

        return $this->success(new ProgressPhotoResource($photo), status: 201);
    }

    public function destroy(ProgressPhoto $progressPhoto): JsonResponse
    {
        $this->progressPhotoService->delete($progressPhoto);

        return $this->success(['message' => 'Progress photo deleted.']);
    }
}
