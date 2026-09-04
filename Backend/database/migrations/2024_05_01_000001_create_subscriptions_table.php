<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('subscriptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('gym_id')->constrained()->cascadeOnDelete();
            $table->string('plan');
            $table->unsignedInteger('member_limit')->nullable();
            $table->date('start_date');
            $table->date('expiry_date');
            $table->string('payment_status')->default('active');
            $table->timestamps();

            $table->index(['gym_id', 'expiry_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subscriptions');
    }
};
