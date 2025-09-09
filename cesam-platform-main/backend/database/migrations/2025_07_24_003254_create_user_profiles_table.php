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
Schema::create('user_profiles', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->unique()->constrained('users')->onDelete('cascade');

    $table->string('ecole')->nullable();
    $table->string('filiere')->nullable();
    $table->string('niveau_etude')->nullable();
    $table->string('ville')->nullable();

    $table->boolean('affilie_amci')->default(false);
    $table->string('matricule_amci')->nullable();

    $table->string('cv_url')->nullable();
    $table->text('biographie')->nullable();
    $table->string('photo_profil')->nullable();

    $table->timestamps();
});

    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_profiles');
    }
};
