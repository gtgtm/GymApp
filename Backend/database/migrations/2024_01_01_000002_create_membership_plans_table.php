<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('membership_plans', function (Blueprint $table) {
            $table->id();
            $table->foreignId('gym_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->unsignedInteger('duration_days');
            $table->decimal('price', 10, 2);
            $table->decimal('registration_fee', 10, 2)->default(0);
            $table->decimal('discount', 10, 2)->default(0);
            $table->decimal('tax', 10, 2)->default(0);
            $table->decimal('total_amount', 10, 2);
            $table->text('description')->nullable();
            $table->json('benefits')->nullable();
            $table->unsignedInteger('freeze_days')->default(0);
            $table->string('status')->default('active');
            $table->timestamps();
            $table->softDeletes();

            $table->index(['gym_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('membership_plans');
    }
};
