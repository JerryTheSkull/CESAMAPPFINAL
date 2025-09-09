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
        Schema::create('registration_step_data', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('process_id');
            $table->integer('step_number');
            $table->json('data');
            $table->timestamps();
            
            $table->foreign('process_id')->references('id')->on('registration_processes')->onDelete('cascade');
            $table->unique(['process_id', 'step_number']);
            $table->index('step_number');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('registration_step_data');
    }
};