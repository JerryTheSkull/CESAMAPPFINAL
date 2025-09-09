<?php

// App/Providers/RouteServiceProvider.php - Ajouter dans configureRateLimiting()

use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Http\Request;
use Illuminate\Cache\RateLimiting\Limit;

class RouteServiceProvider
{
    protected function configureRateLimiting()
    {
        // Rate limiting général pour les APIs
        RateLimiter::for('api', function (Request $request) {
            return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
        });

        // ✅ Rate limiting spécifique pour l'inscription
        RateLimiter::for('registration', function (Request $request) {
            // Limite par IP : 10 tentatives par heure
            return [
                Limit::perHour(10)->by($request->ip()),
                // Limite par email : 3 tentatives par heure (si email fourni)
                Limit::perHour(3)->by($request->input('email', $request->ip()) . ':email'),
            ];
        });

        // ✅ Rate limiting pour l'envoi d'emails de vérification
        RateLimiter::for('verification-email', function (Request $request) {
            // Très restrictif : 3 emails max par heure par IP
            return Limit::perHour(3)->by($request->ip() . ':verification-email');
        });

        // ✅ Rate limiting pour la vérification de codes
        RateLimiter::for('code-verification', function (Request $request) {
            // 10 tentatives de vérification par heure par session
            $sessionToken = $request->input('session_token', $request->ip());
            return Limit::perHour(10)->by($sessionToken . ':code-verification');
        });
    }
}