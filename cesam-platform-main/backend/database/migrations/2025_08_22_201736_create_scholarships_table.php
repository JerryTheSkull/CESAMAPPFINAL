<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('scholarships', function (Blueprint $table) {
            $table->id();
            $table->string('country');
            $table->string('amci_matricule')->unique(); // Unique pour éviter les doublons
            $table->string('name');
            $table->string('passport');
            $table->string('unknown_field')->nullable(); // Nullable si pas toujours rempli
            $table->string('scholarship_code');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('scholarships');
    }
};