<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class PasswordResetCodeMail extends Mailable
{
    use Queueable, SerializesModels;

    public $code;
    public $userEmail;

    public function __construct($code, $email)
    {
        $this->code = $code;
        $this->userEmail = $email;
    }

    public function build()
    {
        return $this->subject('Code de réinitialisation - Cesam')
                    ->html("
                        <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
                            <h2 style='color: #2c3e50;'>Réinitialisation de votre mot de passe</h2>
                            <p>Bonjour,</p>
                            <p>Voici votre code de vérification :</p>
                            <div style='background: #f8f9fa; border: 2px solid #007bff; border-radius: 8px; padding: 20px; text-align: center; margin: 20px 0;'>
                                <h1 style='color: #007bff; font-size: 36px; margin: 0; letter-spacing: 5px;'>{$this->code}</h1>
                            </div>
                            <p><strong>Ce code expire dans 15 minutes.</strong></p>
                            <p>Si vous n'avez pas demandé cette réinitialisation, ignorez ce message.</p>
                            <hr style='border: none; border-top: 1px solid #eee; margin: 30px 0;'>
                            <p style='font-size: 12px; color: #888;'>Email envoyé à {$this->userEmail}</p>
                        </div>
                    ");
    }
}