<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('subscription_plans', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            // Matches the existing subscriptions.plan string column by value —
            // intentionally not a foreign key, so existing subscription rows
            // and Subscription::PLAN_LIMITS keep working unchanged.
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->unsignedInteger('member_limit')->nullable();
            $table->decimal('price', 10, 2)->nullable();
            $table->string('status')->default('active');
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subscription_plans');
    }
};
