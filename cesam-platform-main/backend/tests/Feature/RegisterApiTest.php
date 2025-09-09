<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;
use Spatie\Permission\Models\Role;

class RegisterApiTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Configuration initiale pour les tests
     */
    protected function setUp(): void
    {
        parent::setUp();
        
        // Créer les rôles nécessaires pour les tests
        Role::create(['name' => 'etudiant', 'guard_name' => 'web']);
        Role::create(['name' => 'entreprise', 'guard_name' => 'web']);
        Role::create(['name' => 'admin', 'guard_name' => 'web']);
    }

    /**
     * Test d'inscription complète de l'utilisateur et connexion
     */
    public function test_inscription_complète_et_authentification()
    {
        // Étape 1 : Inscription de base (nom, email, mot de passe)
        $response = $this->postJson('/api/register/step1', [
            'nom_complet' => 'Jean Dupont',
            'email' => 'jean@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(201)
                 ->assertJsonStructure(['message', 'user_id']);

        $userId = $response->json('user_id');

        // Étape 2 : Informations personnelles
        $this->postJson('/api/register/step2', [
            'user_id' => $userId,
            'telephone' => '0612345678',
            'nationalite' => 'Française',
        ])->assertStatus(200)
          ->assertJson(['message' => 'Étape 2 complétée']);

        // Étape 3 : Études
        $this->postJson('/api/register/step3', [
            'user_id' => $userId,
            'niveau_etude' => 'Licence',
            'domaine_etude' => 'Informatique',
        ])->assertStatus(200)
          ->assertJson(['message' => 'Étape 3 complétée']);

        // Étape 4 : Attribution du rôle
        $step4Response = $this->postJson('/api/register/step4', [
            'user_id' => $userId,
            'role' => 'etudiant',
        ]);
        
        $step4Response->assertStatus(200)
          ->assertJson(['message' => 'Étape 4 complétée']);

        // Vérifier que le rôle a bien été assigné
        $user = User::findOrFail($userId);
        $this->assertTrue($user->hasRole('etudiant'));

        // Étape 5 : Vérification du compte
        $this->postJson('/api/register/step5', [
            'user_id' => $userId,
            'verification_token' => $user->verification_token,
            'is_verified' => true,
        ])->assertStatus(200)
          ->assertJson(['message' => 'Étape 5 complétée - utilisateur vérifié']);

        // Connexion de l'utilisateur
        $loginResponse = $this->postJson('/api/login', [
            'email' => 'jean@example.com',
            'password' => 'password123',
        ]);

        $loginResponse->assertStatus(200)
          ->assertJsonStructure([
              'success',
              'message',
              'access_token',
              'token_type',
              'user' => [
                  'id',
                  'nom_complet',
                  'email',
                  'is_verified',
                  'is_approved',
                  'created_at',
                  'updated_at',
              ],
              'role' // Le rôle est au niveau racine de la réponse
          ])
          ->assertJson([
              'success' => true,
              'message' => 'Connecté avec succès',
              'token_type' => 'Bearer',
              'role' => 'etudiant' // Vérifier que le bon rôle est retourné
          ]);

        // Vérifications supplémentaires
        $this->assertNotNull($loginResponse->json('access_token'));
        $this->assertEquals('jean@example.com', $loginResponse->json('user.email'));
        $this->assertEquals('Jean Dupont', $loginResponse->json('user.nom_complet'));
        $this->assertTrue($loginResponse->json('user.is_verified'));
        $this->assertEquals('etudiant', $loginResponse->json('role'));
    }

    /**
     * Test de connexion avec email non vérifié
     */
    public function test_connexion_avec_email_non_verifie()
    {
        // Créer un utilisateur non vérifié
        $user = User::create([
            'nom_complet' => 'Test User',
            'email' => 'test@example.com',
            'password' => bcrypt('password123'),
            'is_verified' => false,
        ]);

        // Assigner un rôle
        $user->assignRole('etudiant');

        // Tenter la connexion
        $response = $this->postJson('/api/login', [
            'email' => 'test@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(403)
                 ->assertJson([
                     'success' => false,
                     'message' => 'Veuillez vérifier votre email',
                 ]);
    }

    /**
     * Test de connexion avec identifiants invalides
     */
    public function test_connexion_avec_identifiants_invalides()
    {
        $response = $this->postJson('/api/login', [
            'email' => 'inexistant@example.com',
            'password' => 'mauvais_password',
        ]);

        $response->assertStatus(401)
                 ->assertJson([
                     'success' => false,
                     'message' => 'Identifiants invalides',
                 ]);
    }

    /**
     * Test de validation des données de connexion
     */
    public function test_validation_donnees_connexion()
    {
        // Email manquant
        $response = $this->postJson('/api/login', [
            'password' => 'password123',
        ]);
        $response->assertStatus(422);

        // Email invalide
        $response = $this->postJson('/api/login', [
            'email' => 'email_invalide',
            'password' => 'password123',
        ]);
        $response->assertStatus(422);

        // Mot de passe trop court
        $response = $this->postJson('/api/login', [
            'email' => 'test@example.com',
            'password' => '123',
        ]);
        $response->assertStatus(422);
    }
}