<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\PasswordResetCode;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller; 

use Illuminate\Support\Str;

class PasswordResetController extends Controller
{
    /**
     * Étape 1 : Envoyer le code de réinitialisation
     */
    public function sendResetCode(Request $request): JsonResponse
    {
        try {
            $request->validate(['email' => 'required|email']);

            $email = $request->input('email');
            $user = User::where('email', $email)->first();

            if (!$user) {
                return response()->json(['message' => 'Email non trouvé'], 404);
            }

            // Générer un code à 6 chiffres
            $code = random_int(100000, 999999);

            PasswordResetCode::updateOrCreate(
                ['email' => $email],
                ['code' => $code, 'token' => null, 'created_at' => now()]
            );

            // Envoyer par mail (exemple simplifié)
            // Remplacer la partie Mail::raw(...) par :

// Email HTML avec mise en forme
$htmlContent = <<<HTML
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Code de vérification</title>
<style>
body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5; margin: 0; padding: 20px; line-height: 1.6; }
.email-container { max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1); overflow: hidden; }
.header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px 30px; text-align: center; }
.header h1 { margin: 0; font-size: 28px; font-weight: 600; }
.header p { margin: 10px 0 0 0; opacity: 0.9; font-size: 16px; }
.content { padding: 40px 30px; text-align: center; }
.content h2 { color: #333; margin-bottom: 20px; font-size: 24px; }
.content p { color: #666; font-size: 16px; margin-bottom: 20px; }
.verification-code { font-size: 36px; font-weight: bold; color: #667eea; letter-spacing: 8px; margin: 30px 0; padding: 25px; border: 3px dashed #667eea; border-radius: 12px; background: linear-gradient(135deg, #f8f9ff 0%, #e8ecff 100%); display: inline-block; min-width: 200px; }
.warning { background: linear-gradient(135deg, #fff3cd 0%, #ffeaa7 100%); color: #856404; padding: 20px; border-radius: 8px; margin: 30px 0; border-left: 4px solid #ffc107; text-align: left; }
.warning strong { display: block; margin-bottom: 10px; font-size: 16px; }
.warning ul { margin: 10px 0; padding-left: 20px; }
.warning li { margin-bottom: 5px; }
.footer { background-color: #f8f9fa; padding: 25px; text-align: center; font-size: 14px; color: #6c757d; border-top: 1px solid #e9ecef; }
.icon { font-size: 48px; margin-bottom: 15px; }
</style>
</head>
<body>
<div class="email-container">
    <div class="header">
        <div class="icon">🔐</div>
        <h1>Code de Vérification</h1>
        <p>Réinitialisation de votre mot de passe</p>
    </div>
    <div class="content">
        <h2>Bonjour !</h2>
        <p>Voici votre code de vérification à 6 chiffres :</p>
        <div class="verification-code">{$code}</div>
        <p>Entrez ce code dans l'application pour continuer.</p>
        <div class="warning">
            <strong>⚠️ Informations importantes :</strong>
            <ul>
                <li>Ce code expire dans <strong>15 minutes</strong></li>
                <li>Ne partagez <strong>jamais</strong> ce code avec quelqu'un</li>
                <li>Si vous n'avez pas demandé cette réinitialisation, ignorez cet email</li>
            </ul>
        </div>
    </div>
    <div class="footer">
        <p><strong>Cet email a été envoyé automatiquement, merci de ne pas répondre.</strong></p>
        <p>&copy; {date('Y')} Votre Application. Tous droits réservés.</p>
        <p style="margin-top: 15px; font-size: 12px; opacity: 0.7;">Code en texte : <strong>{$code}</strong></p>
    </div>
</div>
</body>
</html>
HTML;

// Envoi du mail HTML
Mail::html($htmlContent, function ($message) use ($email) {
    $message->to($email)
            ->subject('Réinitialisation de mot de passe');
});


            return response()->json([
                'message' => 'Code envoyé avec succès'
            ], 200);

        } catch (\Exception $e) {
            Log::error('Erreur sendResetCode: ' . $e->getMessage());
            return response()->json([
                'message' => 'Erreur serveur: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Étape 2 : Vérifier le code
     */
    public function verifyResetCode(Request $request): JsonResponse
    {
        try {
            $request->validate([
                'email' => 'required|email',
                'code' => 'required|digits:6'
            ]);

            $email = $request->input('email');
            $code = $request->input('code');

            $resetCode = PasswordResetCode::where('email', $email)
                ->where('code', $code)
                ->first();

            if (!$resetCode) {
                return response()->json(['message' => 'Code invalide'], 400);
            }

            // Générer un token pour la réinitialisation
            $token = bin2hex(random_bytes(16));
            $resetCode->token = $token;
            $resetCode->save();

            return response()->json([
                'message' => 'Code validé',
                'token' => $token
            ], 200);

        } catch (\Exception $e) {
            Log::error('Erreur verifyResetCode: ' . $e->getMessage());
            return response()->json([
                'message' => 'Erreur serveur: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Étape 3 : Réinitialiser le mot de passe
     */
    public function resetPassword(Request $request): JsonResponse
    {
        try {
            $request->validate([
                'email' => 'required|email',
                'code' => 'required|digits:6',
                'password' => 'required|string|min:8',
                'token' => 'required|string'
            ]);

            $email = $request->input('email');
            $code = $request->input('code');
            $token = $request->input('token');
            $newPassword = $request->input('password');

            $resetCode = PasswordResetCode::where('email', $email)
                ->where('code', $code)
                ->where('token', $token)
                ->first();

            if (!$resetCode) {
                return response()->json(['message' => 'Token ou code invalide'], 400);
            }

            $user = User::where('email', $email)->first();
            if (!$user) {
                return response()->json(['message' => 'Utilisateur non trouvé'], 404);
            }

            $user->password = Hash::make($newPassword);
            $user->save();

            // Supprimer le code pour sécuriser
            $resetCode->delete();

            return response()->json([
                'message' => 'Mot de passe réinitialisé avec succès'
            ], 200);

        } catch (\Exception $e) {
            Log::error('Erreur resetPassword: ' . $e->getMessage());
            return response()->json([
                'message' => 'Erreur serveur: ' . $e->getMessage()
            ], 500);
        }
    }
}
