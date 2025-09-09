<?php

// App/Http/Middleware/RegistrationThrottle.php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Http\Exceptions\ThrottleRequestsException;

class RegistrationThrottle
{
    public function handle(Request $request, Closure $next, $maxAttempts = 10, $decayMinutes = 60)
    {
        $key = $this->resolveRequestSignature($request);
        
        if (RateLimiter::tooManyAttempts($key, $maxAttempts)) {
            $retryAfter = RateLimiter::availableIn($key);
            
            return response()->json([
                'success' => false,
                'message' => 'Trop de tentatives d\'inscription. Veuillez réessayer dans ' . $retryAfter . ' secondes.',
                'retry_after' => $retryAfter
            ], 429);
        }

        RateLimiter::hit($key, $decayMinutes * 60);

        return $next($request);
    }

    protected function resolveRequestSignature(Request $request): string
    {
        // Combiner IP + action pour une clé unique
        $action = $request->route()->getName() ?? $request->path();
        return sha1($request->ip() . '|' . $action);
    }
}
