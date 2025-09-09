<?php

namespace App\Http\Middleware;

use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken as Middleware;

class VerifyCsrfToken extends Middleware
{
    protected $except = [
        // Tu peux ajouter ici des routes API si tu veux désactiver CSRF pour elles
    ];
}
