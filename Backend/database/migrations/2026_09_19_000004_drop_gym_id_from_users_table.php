<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Phase 4 of the multi-gym membership rollout: users.gym_id is no
     * longer read anywhere (GymScope, BelongsToGym, hasRole(),
     * EnforceMemberLimit, and every staff lookup now resolve tenancy from
     * user_gym_memberships via ActingGymContext — see that model's
     * docblock). Dropping it here, rather than leaving it around unused,
     * means any future code that tries to read it fails immediately and
     * loudly instead of silently scoping to a stale or wrong gym.
     *
     * last_acting_gym_id is a SEPARATE column (added in a prior migration)
     * and is intentionally left untouched — it is pure UX convenience
     * (pre-selecting a gym at next login), never read for authorization.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // MySQL requires the FK dropped before the index that backs
            // it — dropConstrainedForeignId's column+FK drop must happen
            // first, in its own statement, before the composite index.
            $table->dropForeign(['gym_id']);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['gym_id', 'role_id']);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('gym_id');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->foreignId('gym_id')->nullable()->after('id')->constrained('gyms')->nullOnDelete();
            $table->index(['gym_id', 'role_id']);
        });
    }
};
