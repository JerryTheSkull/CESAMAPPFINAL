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
        Schema::table('reports', function (Blueprint $table) {
            // Supprimer l'ancien index sur 'field'
            $table->dropIndex(['field', 'status']);
            
            // Renommer la colonne
            $table->renameColumn('field', 'domain');
        });

        // Recréer l'index sur la nouvelle colonne
        Schema::table('reports', function (Blueprint $table) {
            $table->index(['domain', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('reports', function (Blueprint $table) {
            // Supprimer l'index sur 'domain'
            $table->dropIndex(['domain', 'status']);
            
            // Remettre l'ancien nom
            $table->renameColumn('domain', 'field');
        });

        // Recréer l'index sur l'ancienne colonne
        Schema::table('reports', function (Blueprint $table) {
            $table->index(['field', 'status']);
        });
    }
};