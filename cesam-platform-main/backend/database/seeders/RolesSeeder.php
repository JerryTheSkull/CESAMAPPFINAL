<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RolesSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // 🆕 CRÉER LES PERMISSIONS
        $permissions = [
            'view_users',
            'create_users', 
            'edit_users',
            'delete_users',
            'manage_roles',
            'view_profile',
            'edit_profile',
            'delete_profile',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission]);
        }

        // 🆕 CRÉER LES RÔLES
        $adminRole = Role::firstOrCreate(['name' => 'admin']);
        $etudiantRole = Role::firstOrCreate(['name' => 'etudiant']);

        // 🆕 ASSIGNER LES PERMISSIONS AUX RÔLES
        // Admin peut tout faire
        $adminRole->givePermissionTo(Permission::all());

        // Étudiant peut seulement gérer son profil
        $etudiantRole->givePermissionTo([
            'view_profile',
            'edit_profile', 
            'delete_profile'
        ]);

        $this->command->info('✅ Rôles et permissions créés avec succès !');
        $this->command->info('📋 Rôles créés : admin, etudiant');
        $this->command->info('🔑 Permissions assignées selon les rôles');
    }
}