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
            // Ajouter seulement les colonnes manquantes
            $columns = [
                'telephone' => 'string',
                'nationalite' => 'string',
                'ecole' => 'string', 
                'filiere' => 'string',
                'niveau_etude' => 'string',
                'ville' => 'string',
                'cv_url' => 'string',
                'competences' => 'json',
                'projects' => 'json',
                'code_amci' => 'string',
                'affilie_amci' => 'boolean'
            ];
            
            foreach ($columns as $column => $type) {
                if (!Schema::hasColumn('users', $column)) {
                    switch ($type) {
                        case 'json':
                            $table->json($column)->nullable();
                            break;
                        case 'boolean':
                            $table->boolean($column)->default(false);
                            break;
                        default:
                            $table->string($column)->nullable();
                    }
                }
            }
            
            // Colonnes spécifiques à l'inscription
            if (!Schema::hasColumn('users', 'registration_status')) {
                $table->enum('registration_status', [
                    'pending', 'approved', 'rejected', 'incomplete'
                ])->default('pending');
            }
            
            if (!Schema::hasColumn('users', 'registration_completed_at')) {
                $table->timestamp('registration_completed_at')->nullable();
            }
            
            if (!Schema::hasColumn('users', 'registration_process_id')) {
                $table->uuid('registration_process_id')->nullable();
            }
        });
        
        // Ajouter la clé étrangère dans une deuxième étape
        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'registration_process_id')) {
                try {
                    $table->foreign('registration_process_id')
                          ->references('id')
                          ->on('registration_processes')
                          ->onDelete('set null');
                } catch (\Exception $e) {
                    // Ignore si elle existe déjà
                }
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Supprimer la clé étrangère
            try {
                $table->dropForeign(['registration_process_id']);
            } catch (\Exception $e) {
                // Ignore si n'existe pas
            }
            
            // Liste des colonnes à supprimer
            $columnsToRemove = [
                'telephone', 'nationalite', 'ecole', 'filiere', 'niveau_etude',
                'ville', 'cv_url', 'competences', 'projects', 'code_amci',
                'affilie_amci', 'registration_status', 'registration_completed_at',
                'registration_process_id'
            ];
            
            foreach ($columnsToRemove as $column) {
                if (Schema::hasColumn('users', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};