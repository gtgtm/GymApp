<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreTrialRequest;
use App\Http\Requests\Api\V1\UpdateTrialRequest;
use App\Models\Trial;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class TrialController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $trials = Trial::query()
            ->with('trainer.user:id,name', 'enquiry:id,name')
            ->when($request->string('status')->isNotEmpty(), fn ($query) => $query->where('status', $request->string('status')->value()))
            ->latest('trial_start')
            ->get();

        return $this->success($trials);
    }

    public function store(StoreTrialRequest $request): JsonResponse
    {
        $trial = Trial::query()->create([
            ...$request->validated(),
            'status' => $request->validated('status') ?? Trial::STATUS_ACTIVE,
        ]);

        return $this->success($trial, status: 201);
    }

    public function show(Trial $trial): JsonResponse
    {
        return $this->success($trial->load('trainer.user:id,name', 'enquiry'));
    }

    public function update(UpdateTrialRequest $request, Trial $trial): JsonResponse
    {
        $trial->update($request->validated());

        return $this->success($trial);
    }

    public function destroy(Trial $trial): JsonResponse
    {
        $trial->delete();

        return $this->success(['message' => 'Trial deleted.']);
    }

    public function expiringSoon(): JsonResponse
    {
        $trials = Trial::query()
            ->with('trainer.user:id,name')
            ->where('status', Trial::STATUS_ACTIVE)
            ->whereBetween('trial_end', [Carbon::today(), Carbon::today()->addDays(3)])
            ->orderBy('trial_end')
            ->get();

        return $this->success($trials);
    }
}
