<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Mail\VerificationCodeMail;
use Illuminate\Support\Facades\Mail;
use Carbon\Carbon;

class AuthController extends Controller
{
    public function resendVerificationCode(Request $request)
{
    info('📩 [DEBUG] Requête reçue pour resendVerificationCode', $request->all());

    $validated = $request->validate([
        'user_id' => 'required|exists:users,id',
    ]);

    $user = User::findOrFail($validated['user_id']); 
    info('👤 Utilisateur trouvé : ' . $user->email);

    if ($user->is_verified) {
        info('ℹ️ Utilisateur déjà vérifié');
        return response()->json([
            'message' => 'Cet utilisateur est déjà vérifié.'
        ], 400);
    }

    $verificationCode = $user->generateVerificationCode();
    info('🔑 Code généré : ' . $verificationCode);

    try {
        info('🚀 Tentative de connexion SMTP...');
        info('SMTP Host : ' . config('mail.mailers.smtp.host'));
        info('SMTP Port : ' . config('mail.mailers.smtp.port'));
        info('SMTP User : ' . config('mail.mailers.smtp.username'));
        info('FROM : ' . config('mail.from.address'));

        Mail::to($user->email)
            ->send(new VerificationCodeMail($verificationCode, $user->nom_complet));

        if (count(Mail::failures()) > 0) {
            info('⚠️ Échec de l’envoi de l’email. Détails : ', Mail::failures());
            return response()->json([
                'message' => 'Impossible d’envoyer l’email. Vérifie la config SMTP.'
            ], 500);
        }

        info('✅ Email envoyé avec succès à : ' . $user->email);

        return response()->json([
            'message' => 'Un nouveau code de vérification a été envoyé.'
        ]);
    } catch (\Exception $e) {
        info('❌ Erreur lors de l’envoi de l’email : ' . $e->getMessage());
        return response()->json([
            'message' => 'Erreur lors de l’envoi de l’email.',
            'error' => $e->getMessage()
        ], 500);
    }
}


}
