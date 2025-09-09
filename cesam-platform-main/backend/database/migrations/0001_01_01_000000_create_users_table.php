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
        Schema::create('users', function (Blueprint $table) {
            $table->id();

            // Données personnelles
            $table->string('nom_complet');
            $table->string('email')->unique();
            $table->string('password');

            // Contact
            $table->string('telephone')->nullable();
            $table->string('nationalite')->nullable();

            // Études
            $table->string('niveau_etude')->nullable();
            $table->string('domaine_etude')->nullable();

            // Rôle (enum)
            $table->enum('role', ['admin', 'etudiant'])->default('etudiant');

            // Vérification email
            $table->string('verification_token')->nullable();
            $table->boolean('is_verified')->default(false);

            $table->timestamps();
        });

        // Pour réinitialisation de mot de passe
        Schema::create('password_reset_tokens', function (Blueprint $table) {
            $table->string('email')->primary();
            $table->string('token');
            $table->timestamp('created_at')->nullable();
        });

        // Sessions utilisateur
        Schema::create('sessions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->nullable()->index();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->longText('payload');
            $table->integer('last_activity')->index();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('sessions');
        Schema::dropIfExists('password_reset_tokens');
        Schema::dropIfExists('users');
    }
};
