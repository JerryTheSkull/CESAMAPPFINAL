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
        Schema::create('reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('author_name');
            $table->string('title', 500);
            $table->enum('type', ['PFE', 'PFA']);
            $table->integer('defense_year');
            $table->enum('field', [
                'Informatique & Numérique',
                'Génie & Technologies',
                'Sciences & Mathématiques',
                'Économie & Gestion',
                'Droit & Sciences politiques',
                'Médecine & Santé',
                'Arts & Lettres',
                'Enseignement & Pédagogie',
                'Agronomie & Environnement',
                'Tourisme & Hôtellerie',
                'Autres'
            ]);
            $table->text('description')->nullable();
            $table->string('keywords', 500)->nullable();
            $table->string('pdf_path');
            $table->enum('status', ['pending', 'accepted', 'rejected'])->default('pending');
            $table->foreignId('admin_id')->nullable()->constrained('users')->onDelete('set null');
            $table->text('admin_comment')->nullable();
            $table->timestamp('submitted_at')->nullable();
            $table->timestamp('processed_at')->nullable();
            $table->timestamps();
            $table->softDeletes();

            // Index pour améliorer les performances
            $table->index(['status', 'type']);
            $table->index(['field', 'status']);
            $table->index(['defense_year', 'status']);
            $table->index(['user_id', 'status']);
            $table->index('submitted_at');
            $table->index('processed_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reports');
    }
};