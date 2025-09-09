<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\URL;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // Enregistrement des services si nécessaire
        if ($this->app->environment('local')) {
            // Services de développement
        }
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Configuration des permissions et rôles Spatie
        $this->configurePermissions();
        
        // Configuration des Gates (politiques d'accès)
        $this->configureGates();
        
        // Configuration pour la production
        if ($this->app->environment('production')) {
            URL::forceScheme('https');
        }
    }

    /**
     * Configuration des permissions Spatie
     */
    private function configurePermissions(): void
    {
        // Assurer que le cache des permissions est rafraîchi
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // Définir les permissions de base (optionnel - peut être fait via seeder)
        Gate::before(function ($user, $ability) {
            // Super admin bypass (si vous avez ce concept)
            if ($user->hasRole('super-admin')) {
                return true;
            }
        });
    }

    /**
     * Configuration des Gates personnalisés
     */
    private function configureGates(): void
    {
        // Gate pour l'administration des utilisateurs
        Gate::define('manage-users', function ($user) {
            return $user->hasRole('admin');
        });

        // Gate pour l'approbation des utilisateurs
        Gate::define('approve-users', function ($user) {
            return $user->hasRole('admin');
        });

        // Gate pour changer les rôles
        Gate::define('change-user-roles', function ($user) {
            return $user->hasRole('admin');
        });

        // Gate pour supprimer des utilisateurs
        Gate::define('delete-users', function ($user) {
            return $user->hasRole('admin');
        });

        // Gate pour voir les statistiques admin
        Gate::define('view-admin-stats', function ($user) {
            return $user->hasRole('admin');
        });
    }
}