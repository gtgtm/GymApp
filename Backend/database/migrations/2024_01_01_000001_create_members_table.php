<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('members', function (Blueprint $table) {
            $table->id();
            $table->foreignId('gym_id')->constrained()->cascadeOnDelete();
            $table->string('member_code')->unique();
            $table->string('photo_path')->nullable();
            $table->string('full_name');
            $table->string('mobile');
            $table->string('email')->nullable();
            $table->date('date_of_birth')->nullable();
            $table->string('gender')->nullable();
            $table->text('address')->nullable();
            $table->string('emergency_contact_name')->nullable();
            $table->string('emergency_contact_phone')->nullable();
            $table->date('joining_date');
            $table->foreignId('trainer_id')->nullable()->constrained('users')->nullOnDelete();
            $table->decimal('height_cm', 5, 2)->nullable();
            $table->decimal('weight_kg', 5, 2)->nullable();
            $table->string('blood_group')->nullable();
            $table->text('notes')->nullable();
            $table->string('status')->default('active');
            $table->timestamps();
            $table->softDeletes();

            $table->index(['gym_id', 'status']);
            $table->index(['gym_id', 'mobile']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('members');
    }
};
