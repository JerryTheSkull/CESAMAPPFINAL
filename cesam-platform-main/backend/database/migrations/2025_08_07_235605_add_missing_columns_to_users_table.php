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
        Schema::table('users', function (Blueprint $table) {
            // Vérifier et ajouter chaque colonne individuellement
            
            // Étape 1 - Informations personnelles
            if (!Schema::hasColumn('users', 'nom_complet')) {
                $table->string('nom_complet')->nullable()->after('name');
            }
            
            if (!Schema::hasColumn('users', 'telephone')) {
                $table->string('telephone', 20)->nullable()->after('email');
            }
            
            if (!Schema::hasColumn('users', 'nationalite')) {
                $table->string('nationalite', 100)->nullable()->after('telephone');
            }
            
            if (!Schema::hasColumn('users', 'verification_token')) {
                $table->string('verification_token', 64)->nullable()->after('password');
            }
            
            if (!Schema::hasColumn('users', 'is_verified')) {
                $table->boolean('is_verified')->default(false)->after('verification_token');
            }
            
            if (!Schema::hasColumn('users', 'is_approved')) {
                $table->boolean('is_approved')->default(false)->after('is_verified');
            }
            
            // Étape 2 - Éducation
            if (!Schema::hasColumn('users', 'ecole')) {
                $table->string('ecole')->nullable()->after('is_approved');
            }
            
            if (!Schema::hasColumn('users', 'filiere')) {
                $table->string('filiere')->nullable()->after('ecole');
            }
            
            if (!Schema::hasColumn('users', 'niveau_etude')) {
                $table->string('niveau_etude')->nullable()->after('filiere');
            }
            
            if (!Schema::hasColumn('users', 'ville')) {
                $table->string('ville')->nullable()->after('niveau_etude');
            }
            
            // Étape 3 - Profil académique
            if (!Schema::hasColumn('users', 'cv_url')) {
                $table->string('cv_url')->nullable()->after('ville');
            }
            
            if (!Schema::hasColumn('users', 'competences')) {
                $table->json('competences')->nullable()->after('cv_url');
            }
            
            // Étape 4 - AMCI
            if (!Schema::hasColumn('users', 'affilie_amci')) {
                $table->boolean('affilie_amci')->default(false)->after('competences');
            }
            
            if (!Schema::hasColumn('users', 'code_amci')) {
                $table->string('code_amci')->nullable()->after('affilie_amci');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $columns = [
                'nom_complet', 
                'telephone', 
                'nationalite', 
                'verification_token', 
                'is_verified',
                'is_approved',
                'ecole', 
                'filiere', 
                'niveau_etude', 
                'ville', 
                'cv_url', 
                'competences', 
                'affilie_amci',
                'code_amci'
            ];
            
            foreach ($columns as $column) {
                if (Schema::hasColumn('users', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};