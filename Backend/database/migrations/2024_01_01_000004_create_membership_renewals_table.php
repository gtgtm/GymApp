<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('membership_renewals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('gym_id')->constrained()->cascadeOnDelete();
            $table->foreignId('membership_id')->constrained()->cascadeOnDelete();
            $table->foreignId('membership_plan_id')->constrained('membership_plans')->cascadeOnDelete();
            $table->date('previous_expiry');
            $table->date('new_expiry');
            $table->decimal('discount', 10, 2)->default(0);
            $table->decimal('tax', 10, 2)->default(0);
            $table->decimal('amount_paid', 10, 2);
            $table->decimal('amount_due', 10, 2)->default(0);
            $table->string('payment_method');
            $table->foreignId('renewed_by')->constrained('users')->cascadeOnDelete();
            $table->timestamps();

            $table->index(['gym_id', 'membership_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('membership_renewals');
    }
};
