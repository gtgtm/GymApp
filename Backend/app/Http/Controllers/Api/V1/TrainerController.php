<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreTrainerRequest;
use App\Http\Requests\Api\V1\UpdateTrainerRequest;
use App\Models\Trainer;
use App\Services\AuditLogService;
use App\Services\TrainerService;
use Illuminate\Http\JsonResponse;

class TrainerController extends Controller
{
    public function __construct(
        private readonly TrainerService $trainerService,
        private readonly AuditLogService $auditLog,
    ) {}

    public function index(): JsonResponse
    {
        $trainers = Trainer::query()
            ->with('user:id,name,email,phone,status')
            ->withCount('assignedMembers')
            ->get();

        return $this->success($trainers);
    }

    public function store(StoreTrainerRequest $request): JsonResponse
    {
        $trainer = $this->trainerService->create($request->validated());

        $this->auditLog->log('trainer.created', $trainer, null, $trainer->toArray());

        return $this->success($trainer->load('user'), status: 201);
    }

    public function show(Trainer $trainer): JsonResponse
    {
        return $this->success(
            $trainer->load('user', 'assignedMembers:id,full_name,member_code,trainer_id')
        );
    }

    public function update(UpdateTrainerRequest $request, Trainer $trainer): JsonResponse
    {
        $before = $trainer->toArray();
        $updated = $this->trainerService->update($trainer, $request->validated());

        $this->auditLog->log('trainer.updated', $trainer, $before, $updated->toArray());

        return $this->success($updated);
    }

    public function destroy(Trainer $trainer): JsonResponse
    {
        $this->auditLog->log('trainer.deleted', $trainer, $trainer->toArray());
        $trainer->delete();

        return $this->success(['message' => 'Trainer deleted.']);
    }
}
