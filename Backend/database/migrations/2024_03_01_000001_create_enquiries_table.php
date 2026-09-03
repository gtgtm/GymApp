<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('enquiries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('gym_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('mobile');
            $table->string('email')->nullable();
            $table->string('source')->nullable();
            $table->foreignId('interested_plan_id')->nullable()->constrained('membership_plans')->nullOnDelete();
            $table->date('follow_up_date')->nullable();
            $table->foreignId('assigned_staff_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('status')->default('new');
            $table->text('notes')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['gym_id', 'status']);
            $table->index(['gym_id', 'follow_up_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('enquiries');
    }
};
