<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class LogoutController extends Controller
{
    /**
     * Déconnexion simple (appareil actuel uniquement)
     */
    public function logout(Request $request)
    {
        try {
            $user = $request->user();
            
            // Supprimer le token actuel uniquement
            $request->user()->currentAccessToken()->delete();
            
            Log::info('Déconnexion réussie pour l\'utilisateur: ' . $user->email);
            
            return response()->json([
                'success' => true,
                'message' => 'Déconnecté avec succès'
            ]);
            
        } catch (\Exception $e) {
            Log::error('Erreur lors de la déconnexion: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la déconnexion'
            ], 500);
        }
    }
    
    /**
     * Déconnexion de tous les appareils
     */
    public function logoutAll(Request $request)
    {
        try {
            $user = $request->user();
            
            // Supprimer TOUS les tokens de l'utilisateur
            $user->tokens()->delete();
            
            Log::info('Déconnexion complète pour l\'utilisateur: ' . $user->email);
            
            return response()->json([
                'success' => true,
                'message' => 'Déconnecté de tous les appareils avec succès'
            ]);
            
        } catch (\Exception $e) {
            Log::error('Erreur lors de la déconnexion complète: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la déconnexion'
            ], 500);
        }
    }
}