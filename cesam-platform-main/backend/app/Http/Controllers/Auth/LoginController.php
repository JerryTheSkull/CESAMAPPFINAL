<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class LoginController extends Controller
{
    /**
     * Handle an API login request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(Request $request)
    {
        // Validation des données
        $validated = $request->validate([
            'email' => 'required|email',
            'password' => 'required|string|min:6',
        ]);

        try {
            // Trouver l'utilisateur par email
            $user = User::where('email', $validated['email'])->first();

            // Vérifier si l'utilisateur existe et si le mot de passe est correct
            if (!$user || !Hash::check($validated['password'], $user->password)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Email ou mot de passe incorrect'
                ], 401);
            }

            // Vérifier si l'email est vérifié
            if (!$user->is_verified) {
                return response()->json([
                    'success' => false,
                    'message' => 'Votre email n\'est pas encore vérifié. Vérifiez votre boîte mail.',
                    'email_verified' => false
                ], 403);
            }

            // Optionnel : Vérifier si le compte est approuvé
            if (!$user->is_approved) {
                return response()->json([
                    'success' => false,
                    'message' => 'Votre compte est en attente d\'approbation.',
                    'account_approved' => false
                ], 403);
            }

            // Révoquer les anciens tokens (optionnel)
            $user->tokens()->delete();

            // Créer un nouveau token
            $token = $user->createToken('auth-token')->plainTextToken;

            // Récupérer le rôle de l'utilisateur
            $userRole = $user->getRoleNames()->first() ?? 'student'; // Par défaut 'student'

            return response()->json([
                'success' => true,
                'message' => 'Connexion réussie',
                'access_token' => $token,
                'token_type' => 'Bearer',
                'user' => [
                    'id' => $user->id,
                    'nom_complet' => $user->nom_complet,
                    'email' => $user->email,
                    'telephone' => $user->telephone,
                    'nationalite' => $user->nationalite,
                    'ecole' => $user->ecole,
                    'filiere' => $user->filiere,
                    'niveau_etude' => $user->niveau_etude,
                    'ville' => $user->ville,
                    'cv_url' => $user->cv_url,
                    'competences' => $user->competences,
                    'affilie_amci' => $user->affilie_amci,
                    'code_amci' => $user->code_amci,
                    'is_verified' => $user->is_verified,
                    'is_approved' => $user->is_approved,
                ],
                'role' => $userRole,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la connexion : ' . $e->getMessage()
            ], 500);
        }
    }
}