<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('body_measurements', function (Blueprint $table) {
            $table->id();
            $table->foreignId('gym_id')->constrained()->cascadeOnDelete();
            $table->foreignId('member_id')->constrained()->cascadeOnDelete();
            $table->date('recorded_date');
            $table->decimal('weight_kg', 6, 2)->nullable();
            $table->decimal('height_cm', 6, 2)->nullable();
            $table->decimal('bmi', 6, 2)->nullable();
            $table->decimal('body_fat_percent', 5, 2)->nullable();
            $table->decimal('chest_cm', 6, 2)->nullable();
            $table->decimal('waist_cm', 6, 2)->nullable();
            $table->decimal('arms_cm', 6, 2)->nullable();
            $table->decimal('thigh_cm', 6, 2)->nullable();
            $table->decimal('hips_cm', 6, 2)->nullable();
            $table->foreignId('recorded_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->index(['gym_id', 'member_id', 'recorded_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('body_measurements');
    }
};
