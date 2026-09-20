<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_gym_memberships', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('gym_id')->constrained()->cascadeOnDelete();
            $table->foreignId('role_id')->constrained();
            // The member profile for THIS gym, if any. Nullable because a
            // membership can be staff-only (admin/receptionist/trainer),
            // which has no members row.
            $table->foreignId('member_id')->nullable()->constrained()->nullOnDelete();
            // pending: created by another gym via join-by-email, awaiting the
            // person's own confirmation before it counts as active.
            // revoked: gym removed this person's access; row is kept for
            // history instead of being deleted, so this table has no
            // soft-deletes column (that would fight the unique constraint
            // below — see class docblock on UserGymMembership).
            $table->string('status')->default('active');
            $table->timestamp('joined_at')->nullable();
            $table->timestamps();

            // One membership per person per gym, ever.
            $table->unique(['user_id', 'gym_id']);
            $table->unique('member_id');
            $table->index(['gym_id', 'role_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_gym_memberships');
    }
};
