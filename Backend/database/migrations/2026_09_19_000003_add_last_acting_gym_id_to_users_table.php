<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Pure UX convenience: which gym to pre-select next login for a
     * multi-membership user. Never read for authorization or tenant
     * scoping — that is exclusively ActingGymContext, resolved fresh per
     * request by ResolveActingGym. Distinct from users.gym_id, which for
     * now remains the legacy single-tenant column (see Phase 3/4 notes on
     * UserGymMembership) and is left completely untouched here.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->foreignId('last_acting_gym_id')->nullable()->after('gym_id')->constrained('gyms')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropConstrainedForeignId('last_acting_gym_id');
        });
    }
};
