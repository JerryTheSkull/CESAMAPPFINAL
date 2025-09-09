<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 🆕 ÉTAPE 1 : Créer les rôles et permissions AVANT les utilisateurs
        $this->call(RolesSeeder::class);

        // 🆕 ÉTAPE 2 : Créer les utilisateurs (ils auront automatiquement le rôle étudiant)
        
        // Créer un utilisateur test normal (rôle étudiant automatique)
        $testUser = User::factory()->create([
            'nom_complet' => 'Test Étudiant',
            'email' => 'etudiant@test.com',
            'email_verified_at' => now(), // Email déjà vérifié pour les tests
        ]);

        // 🆕 CRÉER UN ADMIN MANUELLEMENT (car on veut qu'il soit admin, pas étudiant)
        $adminUser = User::factory()->create([
            'nom_complet' => 'Super Admin',
            'email' => 'admin@cesam.com',
            'email_verified_at' => now(),
            'telephone' => '+212600000000',
            'nationalite' => 'Maroc',
        ]);

        // 🆕 IMPORTANT : Retirer le rôle étudiant et assigner admin
        $adminUser->removeRole('etudiant');
        $adminUser->assignRole('admin');

        // 🆕 Créer quelques utilisateurs supplémentaires pour tester
        User::factory(5)->create()->each(function ($user) {
            $user->update(['email_verified_at' => now()]);
        });

        $this->command->info('✅ Base de données peuplée avec succès !');
        $this->command->info('👤 Admin créé : admin@cesam.com (mot de passe: password)');
        $this->command->info('🎓 Utilisateur test : etudiant@test.com (mot de passe: password)');
        $this->command->info('📚 5 étudiants supplémentaires créés automatiquement');
    }
}