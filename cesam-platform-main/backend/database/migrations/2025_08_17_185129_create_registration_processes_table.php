<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('registration_processes', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('session_token', 64)->unique();
            $table->string('user_email')->nullable()->index();
            $table->tinyInteger('current_step')->default(1);
            $table->tinyInteger('total_steps')->default(5);
            $table->enum('status', ['in_progress', 'completed', 'abandoned', 'expired'])->default('in_progress');
            $table->json('metadata')->nullable();
            $table->timestamp('expires_at');
            $table->timestamps();
            
            $table->index(['status', 'created_at']);
            $table->index(['expires_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('registration_processes');
    }
};