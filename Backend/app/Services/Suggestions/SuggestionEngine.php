<?php

declare(strict_types=1);

namespace App\Services\Suggestions;

use App\Services\Suggestions\Rules\AttendanceTrendRule;
use App\Services\Suggestions\Rules\ExpiringMembershipsRule;
use App\Services\Suggestions\Rules\InactiveMembersRule;
use App\Services\Suggestions\Rules\PendingPaymentsRule;
use App\Services\Suggestions\Rules\PopularPlanRule;
use App\Services\Suggestions\Rules\RevenueTrendRule;
use App\Services\Suggestions\Rules\TrialsExpiringSoonRule;
use App\Services\Suggestions\Rules\UncontactedLeadsRule;

class SuggestionEngine
{
    /**
     * @var SuggestionRule[]
     */
    private readonly array $rules;

    public function __construct()
    {
        $this->rules = [
            new ExpiringMembershipsRule,
            new InactiveMembersRule,
            new PendingPaymentsRule,
            new UncontactedLeadsRule,
            new TrialsExpiringSoonRule,
            new PopularPlanRule,
            new AttendanceTrendRule,
            new RevenueTrendRule,
        ];
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    public function suggestions(): array
    {
        $suggestions = [];

        foreach ($this->rules as $rule) {
            foreach ($rule->generate() as $suggestion) {
                $suggestions[] = $suggestion->toArray();
            }
        }

        return $suggestions;
    }
}
