<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('workout_exercises', function (Blueprint $table) {
            $table->id();
            $table->foreignId('gym_id')->constrained()->cascadeOnDelete();
            $table->foreignId('workout_plan_id')->constrained()->cascadeOnDelete();
            $table->unsignedTinyInteger('day_number');
            $table->string('day_label')->nullable();
            $table->string('exercise_name');
            $table->string('muscle_group')->nullable();
            $table->unsignedInteger('sets')->nullable();
            $table->string('reps')->nullable();
            $table->decimal('weight_kg', 6, 2)->nullable();
            $table->unsignedInteger('rest_seconds')->nullable();
            $table->text('instructions')->nullable();
            $table->string('video_url')->nullable();
            $table->text('trainer_notes')->nullable();
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();

            $table->index(['workout_plan_id', 'day_number']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('workout_exercises');
    }
};
