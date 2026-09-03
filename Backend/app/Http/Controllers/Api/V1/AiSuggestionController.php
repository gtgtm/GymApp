<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\Suggestions\SuggestionEngine;
use Illuminate\Http\JsonResponse;

class AiSuggestionController extends Controller
{
    public function __construct(private readonly SuggestionEngine $suggestionEngine) {}

    public function index(): JsonResponse
    {
        return $this->success($this->suggestionEngine->suggestions());
    }
}
