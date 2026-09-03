<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\GymNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $notifications = GymNotification::query()
            ->where('user_id', $request->user()->id)
            ->when($request->boolean('unread_only'), fn ($query) => $query->whereNull('read_at'))
            ->latest()
            ->limit(50)
            ->get();

        return $this->success($notifications, [
            'unread_count' => GymNotification::query()
                ->where('user_id', $request->user()->id)
                ->whereNull('read_at')
                ->count(),
        ]);
    }

    public function markRead(Request $request, GymNotification $notification): JsonResponse
    {
        abort_unless($notification->user_id === $request->user()->id, 403);

        $notification->update(['read_at' => now()]);

        return $this->success($notification);
    }

    public function markAllRead(Request $request): JsonResponse
    {
        GymNotification::query()
            ->where('user_id', $request->user()->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return $this->success(['message' => 'All notifications marked as read.']);
    }
}
