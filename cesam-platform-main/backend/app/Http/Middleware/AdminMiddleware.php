<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;
use App\Models\User;

class AdminMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Vérifier si l'utilisateur est connecté
        if (!Auth::check()) {
            return response()->json([
                'success' => false,
                'message' => 'Non authentifié. Veuillez vous connecter.'
            ], 401);
        }

        // Récupérer l'utilisateur connecté
        /** @var User $user */
        $user = Auth::user();

        // Vérifier si l'utilisateur existe
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Utilisateur non trouvé.'
            ], 401);
        }

        // Méthode 1: Utiliser hasRole (recommandé)
        if (method_exists($user, 'hasRole') && !$user->hasRole('admin')) {
            return response()->json([
                'success' => false,
                'message' => 'Accès refusé. Droits administrateur requis.'
            ], 403);
        }

        // Méthode 2: Alternative - vérifier les rôles manuellement
        // if (!$user->roles()->where('name', 'admin')->exists()) {
        //     return response()->json([
        //         'success' => false,
        //         'message' => 'Accès refusé. Droits administrateur requis.'
        //     ], 403);
        // }

        return $next($request);
    }
}