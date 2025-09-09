<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PasswordResetCode extends Model
{
    use HasFactory;

    protected $fillable = [
        'email',
        'code',
        'token',
        'expires_at',
        'attempts'
    ];

    protected $casts = [
        'expires_at' => 'datetime',
    ];

    /**
     * Créer un nouveau code de réinitialisation avec token
     */
    public static function createForEmailWithToken($email, $token)
    {
        // Supprimer les anciens codes pour cet email
        self::where('email', $email)->delete();
        
        // Créer un nouveau code
        return self::create([
            'email' => $email,
            'code' => str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT),
            'token' => $token,
            'expires_at' => now()->addMinutes(15),
            'attempts' => 0,
        ]);
    }

    /**
     * Méthode existante (gardez-la si elle existe déjà)
     */
    public static function createForEmail($email)
    {
        // Supprimer les anciens codes pour cet email
        self::where('email', $email)->delete();
        
        // Créer un nouveau code
        return self::create([
            'email' => $email,
            'code' => str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT),
            'expires_at' => now()->addMinutes(15),
            'attempts' => 0,
        ]);
    }

    /**
     * Vérifier un code
     */
    public static function verifyCode($email, $code)
    {
        $resetCode = self::where('email', $email)
            ->where('code', $code)
            ->where('expires_at', '>', now())
            ->first();

        if ($resetCode) {
            $resetCode->increment('attempts');
            return true;
        }

        return false;
    }

    /**
     * Supprimer un code utilisé
     */
    public static function deleteUsedCode($email, $code)
    {
        self::where('email', $email)
            ->where('code', $code)
            ->delete();
    }
}