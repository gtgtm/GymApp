<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * One membership per existing gym-bound user (super_admin, whose
     * gym_id is null, gets none — it is platform-level, not gym-level).
     * Idempotent: re-running skips rows that already exist for a
     * (user_id, gym_id) pair, so this is safe to run more than once.
     */
    public function up(): void
    {
        $users = DB::table('users')
            ->whereNotNull('gym_id')
            ->select('id', 'gym_id', 'role_id', 'status', 'created_at')
            ->get();

        $now = now();

        $rows = $users->map(fn ($user) => [
            'user_id' => $user->id,
            'gym_id' => $user->gym_id,
            'role_id' => $user->role_id,
            'status' => $user->status,
            'joined_at' => $user->created_at,
            'created_at' => $now,
            'updated_at' => $now,
        ])->all();

        foreach (array_chunk($rows, 500) as $chunk) {
            DB::table('user_gym_memberships')->insertOrIgnore($chunk);
        }

        // Attach each membership to its member profile, where one exists.
        // Looped rather than a single UPDATE ... JOIN so this works
        // identically on MySQL (production) and SQLite (test suite).
        DB::table('members')
            ->whereNotNull('user_id')
            ->select('user_id', 'gym_id', 'id')
            ->orderBy('id')
            ->chunk(500, function ($members): void {
                foreach ($members as $member) {
                    DB::table('user_gym_memberships')
                        ->where('user_id', $member->user_id)
                        ->where('gym_id', $member->gym_id)
                        ->whereNull('member_id')
                        ->update(['member_id' => $member->id]);
                }
            });

        $membershipCount = DB::table('user_gym_memberships')->count();
        $expectedCount = $users->count();

        if ($membershipCount < $expectedCount) {
            throw new RuntimeException(
                "Backfill produced {$membershipCount} memberships but expected at least {$expectedCount} gym-bound users. Aborting migration."
            );
        }
    }

    public function down(): void
    {
        DB::table('user_gym_memberships')->truncate();
    }
};
