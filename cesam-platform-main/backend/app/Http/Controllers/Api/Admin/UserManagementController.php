<?php

namespace App\Http\Controllers\Api\Admin;

use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Exception;

class UserManagementController extends Controller
{
    /**
     * 📋 LISTER LES UTILISATEURS (simplifié pour admin/etudiant)
     */
    public function getUsers(Request $request)
    {
        try {
            $query = User::with('roles');

            // Filtres
            if ($request->has('verified')) {
                $query->where('is_verified', $request->boolean('verified'));
            }

            if ($request->has('approved')) {
                $query->where('is_approved', $request->boolean('approved'));
            }

            // Filtre par rôle (seulement admin ou etudiant)
            if ($request->has('role') && in_array($request->role, ['admin', 'etudiant'])) {
                $query->whereHas('roles', function($q) use ($request) {
                    $q->where('name', $request->role);
                });
            }

            // Recherche
            if ($request->has('search')) {
                $search = $request->search;
                $query->where(function($q) use ($search) {
                    $q->where('nom_complet', 'like', "%$search%")
                      ->orWhere('email', 'like', "%$search%");
                });
            }

            $users = $query->select([
                'id', 'nom_complet', 'email', 
                'is_verified', 'is_approved', 'created_at'
            ])->get();

            $formattedUsers = $users->map(function($user) {
                return [
                    'id' => $user->id,
                    'nom_complet' => $user->nom_complet,
                    'email' => $user->email,
                    'is_verified' => $user->is_verified,
                    'is_approved' => $user->is_approved,
                    'created_at' => $user->created_at,
                    'roles' => $user->getRoleNames()->toArray(),
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $formattedUsers,
                'meta' => [
                    'total' => $users->count(),
                    'can_be_approved' => $users->where('is_verified', 1)->where('is_approved', 0)->count(),
                    'can_change_role' => $users->where('is_approved', 1)->count()
                ]
            ]);

        } catch (Exception $e) {
            Log::error('Erreur getUsers : ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des utilisateurs',
                'error' => config('app.debug') ? $e->getMessage() : 'Erreur interne'
            ], 500);
        }
    }

    /**
     * 📊 STATISTIQUES (pour 2 rôles)
     */
    public function getStats()
    {
        try {
            return response()->json([
                'success' => true,
                'stats' => [
                    'total_users' => User::count(),
                    'verified_users' => User::where('is_verified', 1)->count(),
                    'approved_users' => User::where('is_approved', 1)->count(),
                    'pending_approval' => User::where('is_verified', 1)->where('is_approved', 0)->count(),
                    'roles' => [
                        'admin' => User::role('admin')->count(),
                        'etudiant' => User::role('etudiant')->count()
                    ]
                ]
            ]);
        } catch (Exception $e) {
            Log::error('Erreur getStats : ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors des statistiques',
                'error' => config('app.debug') ? $e->getMessage() : 'Erreur interne'
            ], 500);
        }
    }

    /**
     * 2️⃣ CHANGER LE RÔLE (seulement admin <-> etudiant)
     */
    public function changeRole(Request $request, $userId)
    {
        $request->validate([
            'role' => 'required|in:admin,etudiant'
        ]);

        try {
            $user = User::findOrFail($userId);

            if (!$user->is_approved) {
                return response()->json([
                    'success' => false,
                    'message' => 'Impossible de changer le rôle : l\'utilisateur n\'est pas approuvé'
                ], 400);
            }

            $newRole = $request->input('role');
            $oldRoles = $user->getRoleNames()->toArray();

            $user->syncRoles([$newRole]);

            return response()->json([
                'success' => true,
                'message' => "Rôle changé vers '$newRole' avec succès",
                'user' => [
                    'id' => $user->id,
                    'nom_complet' => $user->nom_complet,
                    'email' => $user->email,
                    'old_roles' => $oldRoles,
                    'new_roles' => $user->fresh()->getRoleNames()->toArray(),
                ]
            ]);

        } catch (Exception $e) {
            Log::error('Erreur changeRole : ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du changement de rôle',
                'error' => config('app.debug') ? $e->getMessage() : 'Erreur interne'
            ], 500);
        }
    }

    /**
     * 1️⃣ APPROUVER/DÉSAPPROUVER
     */
    public function approveUser(Request $request, $userId)
    {
        $request->validate([
            'action' => 'required|in:approve,disapprove'
        ]);

        try {
            $user = User::findOrFail($userId);

            if (!$user->is_verified) {
                return response()->json([
                    'success' => false,
                    'message' => 'Impossible d\'approuver : l\'utilisateur n\'est pas vérifié'
                ], 400);
            }

            $action = $request->input('action');
            $user->is_approved = ($action === 'approve') ? 1 : 0;
            $user->save();

            return response()->json([
                'success' => true,
                'message' => ($action === 'approve') ? 'Utilisateur approuvé' : 'Utilisateur désapprouvé',
                'user' => [
                    'id' => $user->id,
                    'nom_complet' => $user->nom_complet,
                    'email' => $user->email,
                    'is_approved' => $user->is_approved,
                    'roles' => $user->getRoleNames()->toArray(),
                ]
            ]);

        } catch (Exception $e) {
            Log::error('Erreur approveUser : ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'approbation',
                'error' => config('app.debug') ? $e->getMessage() : 'Erreur interne'
            ], 500);
        }
    }

    /**
     * 3️⃣ SUPPRIMER
     */
    public function deleteUser($userId)
    {
        try {
            $user = User::findOrFail($userId);
            
            $userData = [
                'id' => $user->id,
                'nom_complet' => $user->nom_complet,
                'email' => $user->email,
                'roles' => $user->getRoleNames()->toArray()
            ];

            $user->delete();

            return response()->json([
                'success' => true,
                'message' => 'Utilisateur supprimé avec succès',
                'deleted_user' => $userData
            ]);

        } catch (Exception $e) {
            Log::error('Erreur deleteUser : ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la suppression',
                'error' => config('app.debug') ? $e->getMessage() : 'Erreur interne'
            ], 500);
        }
    }

    /**
     * 🆕 RÔLES DISPONIBLES (seulement 2)
     */
    public function getAvailableRoles()
    {
        return response()->json([
            'success' => true,
            'roles' => [
                ['id' => 1, 'name' => 'admin'],
                ['id' => 2, 'name' => 'etudiant']
            ]
        ]);
    }
}