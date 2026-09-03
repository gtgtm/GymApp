<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;

abstract class Controller
{
    protected function success(mixed $data = null, ?array $meta = null, int $status = 200): JsonResponse
    {
        return response()->json(array_filter([
            'success' => true,
            'data' => $data,
            'error' => null,
            'meta' => $meta,
        ], fn ($value, $key) => $key !== 'meta' || $value !== null, ARRAY_FILTER_USE_BOTH), $status);
    }

    protected function fail(string $message, int $status = 400, mixed $errors = null): JsonResponse
    {
        return response()->json([
            'success' => false,
            'data' => null,
            'error' => [
                'message' => $message,
                'errors' => $errors,
            ],
        ], $status);
    }
}
