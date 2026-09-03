<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreEnquiryRequest;
use App\Http\Requests\Api\V1\UpdateEnquiryRequest;
use App\Models\Enquiry;
use App\Services\AuditLogService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class EnquiryController extends Controller
{
    public function __construct(private readonly AuditLogService $auditLog) {}

    public function index(Request $request): JsonResponse
    {
        $enquiries = Enquiry::query()
            ->with('interestedPlan:id,name', 'assignedStaff:id,name')
            ->when($request->string('status')->isNotEmpty(), fn ($query) => $query->where('status', $request->string('status')->value()))
            ->when($request->string('search')->isNotEmpty(), function ($query) use ($request) {
                $search = $request->string('search')->value();
                $query->where(function ($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%")->orWhere('mobile', 'like', "%{$search}%");
                });
            })
            ->latest()
            ->get();

        return $this->success($enquiries);
    }

    public function store(StoreEnquiryRequest $request): JsonResponse
    {
        $enquiry = Enquiry::query()->create([
            ...$request->validated(),
            'status' => $request->validated('status') ?? Enquiry::STATUS_NEW,
        ]);

        $this->auditLog->log('enquiry.created', $enquiry, null, $enquiry->toArray());

        return $this->success($enquiry, status: 201);
    }

    public function show(Enquiry $enquiry): JsonResponse
    {
        return $this->success($enquiry->load('interestedPlan', 'assignedStaff', 'trials'));
    }

    public function update(UpdateEnquiryRequest $request, Enquiry $enquiry): JsonResponse
    {
        $before = $enquiry->toArray();
        $enquiry->update($request->validated());

        $this->auditLog->log('enquiry.updated', $enquiry, $before, $enquiry->toArray());

        return $this->success($enquiry);
    }

    public function destroy(Enquiry $enquiry): JsonResponse
    {
        $this->auditLog->log('enquiry.deleted', $enquiry, $enquiry->toArray());
        $enquiry->delete();

        return $this->success(['message' => 'Enquiry deleted.']);
    }

    public function conversionStats(): JsonResponse
    {
        $total = Enquiry::query()->count();
        $converted = Enquiry::query()->where('status', Enquiry::STATUS_CONVERTED)->count();

        $byStatus = Enquiry::query()
            ->selectRaw('status, count(*) as count')
            ->groupBy('status')
            ->pluck('count', 'status');

        return $this->success([
            'total' => $total,
            'converted' => $converted,
            'conversion_rate' => $total > 0 ? round(($converted / $total) * 100, 1) : 0,
            'by_status' => $byStatus,
        ]);
    }
}
