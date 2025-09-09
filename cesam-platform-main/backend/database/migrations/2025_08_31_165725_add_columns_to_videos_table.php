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
        Schema::table('videos', function (Blueprint $table) {
            $table->string('titre')->after('id');
            $table->text('description')->nullable()->after('titre');
            $table->string('url', 500)->after('description');
            $table->string('miniature')->nullable()->after('url');
            $table->enum('theme', ['Chaîne TV étudiante', 'Documentaires & Films'])->after('miniature');
            $table->boolean('is_live')->default(false)->after('theme');
            $table->boolean('is_active')->default(true)->after('is_live');
            $table->integer('duree')->nullable()->after('is_active'); // durée en secondes
            $table->integer('vues')->default(0)->after('duree');
            $table->integer('likes')->default(0)->after('vues');
            $table->datetime('date_publication')->default(now())->after('likes');
            $table->foreignId('auteur_id')->constrained('users')->onDelete('cascade')->after('date_publication');

            // Index pour optimiser les requêtes
            $table->index(['is_active', 'theme']);
            $table->index(['is_live']);
            $table->index('date_publication');
            $table->index('auteur_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function reverse(): void
    {
        Schema::table('videos', function (Blueprint $table) {
            $table->dropIndex(['is_active', 'theme']);
            $table->dropIndex(['is_live']);
            $table->dropIndex(['date_publication']);
            $table->dropIndex(['auteur_id']);
            
            $table->dropForeign(['auteur_id']);
            $table->dropColumn([
                'titre', 'description', 'url', 'miniature', 'theme',
                'is_live', 'is_active', 'duree', 'vues', 'likes',
                'date_publication', 'auteur_id'
            ]);
        });
    }
};