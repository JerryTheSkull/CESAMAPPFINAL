<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\User>
 */
class UserFactory extends Factory
{
    /**
     * The current password being used by the factory.
     */
    protected static ?string $password;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'nom_complet' => fake()->name(),  // Changé de 'name' à 'nom_complet'
            'email' => fake()->unique()->safeEmail(),
            'email_verified_at' => now(),
            'password' => static::$password ??= Hash::make('password'),
            'remember_token' => Str::random(10),
            'telephone' => fake()->phoneNumber(),
            'nationalite' => fake()->randomElement(['Maroc', 'France', 'Algérie', 'Tunisie', 'Sénégal']),
            'ecole' => fake()->randomElement(['ENSIAS', 'EMI', 'INPT', 'FST', 'EST']),
            'filiere' => fake()->randomElement(['Informatique', 'Génie Civil', 'Électronique', 'Mécanique']),
            'niveau_etude' => fake()->randomElement(['Licence', 'Master', 'Doctorat']),
            'ville' => fake()->city(),
            'is_verified' => true,
            'is_approved' => true,
            'status' => 'active',
            'registration_status' => 'completed',
            'affilie_amci' => fake()->boolean(30), // 30% de chance d'être affilié AMCI
        ];
    }

    /**
     * Indicate that the model's email address should be unverified.
     */
    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
            'is_verified' => false,
        ]);
    }

    /**
     * Create an admin user.
     */
    public function admin(): static
    {
        return $this->state(fn (array $attributes) => [
            'nom_complet' => 'Admin CESAM',
            'is_verified' => true,
            'is_approved' => true,
            'status' => 'active',
        ]);
    }

    /**
     * Create a student user.
     */
    public function student(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_verified' => true,
            'is_approved' => true,
            'status' => 'active',
            'registration_status' => 'completed',
        ]);
    }
}