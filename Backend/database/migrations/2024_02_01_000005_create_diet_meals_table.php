<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('diet_meals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('gym_id')->constrained()->cascadeOnDelete();
            $table->foreignId('diet_plan_id')->constrained()->cascadeOnDelete();
            $table->string('meal_slot');
            $table->string('food_item');
            $table->string('quantity')->nullable();
            $table->decimal('calories', 8, 2)->nullable();
            $table->decimal('protein_g', 8, 2)->nullable();
            $table->decimal('carbs_g', 8, 2)->nullable();
            $table->decimal('fat_g', 8, 2)->nullable();
            $table->text('notes')->nullable();
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();

            $table->index(['diet_plan_id', 'meal_slot']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('diet_meals');
    }
};
