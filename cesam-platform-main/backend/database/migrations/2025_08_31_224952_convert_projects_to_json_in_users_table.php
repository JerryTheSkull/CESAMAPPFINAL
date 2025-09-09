<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

return new class extends Migration
{
    public function up()
    {
        // 1. Vérifier l'état actuel
        $columns = DB::select("SHOW COLUMNS FROM users WHERE Field = 'projects'");
        
        if (!empty($columns)) {
            $currentType = $columns[0]->Type;
            Log::info("Type actuel de la colonne projects: " . $currentType);
            
            // 2. Si ce n'est pas déjà JSON, convertir
            if (strpos(strtolower($currentType), 'json') === false) {
                
                // 3. Nettoyer les données existantes si nécessaire
                // Convertir les chaînes vides ou nulles en JSON valide
                DB::update("
                    UPDATE users 
                    SET projects = CASE 
                        WHEN projects IS NULL OR projects = '' THEN '[]'
                        WHEN projects LIKE '{%' OR projects LIKE '[%' THEN projects
                        ELSE '[]'
                    END
                ");
                
                // 4. Convertir le type de colonne
                DB::statement('ALTER TABLE users MODIFY COLUMN projects JSON NULL');
                
                Log::info("Colonne projects convertie de LONGTEXT vers JSON");
            } else {
                Log::info("Colonne projects est déjà de type JSON");
            }
        } else {
            // Créer la colonne si elle n'existe pas (cas improbable)
            Schema::table('users', function (Blueprint $table) {
                $table->json('projects')->nullable()->after('competences');
            });
            Log::info("Colonne projects créée en JSON");
        }
    }

    public function down()
    {
        // Conversion inverse si nécessaire
        DB::statement('ALTER TABLE users MODIFY COLUMN projects LONGTEXT NULL');
    }
};