<?php

namespace App\Http\Middleware;

use Illuminate\Http\Middleware\TrustProxies as Middleware;
use Symfony\Component\HttpFoundation\Request as SymfonyRequest;

class TrustProxies extends Middleware
{
    /**
     * Définir les proxies de confiance ici. '*' signifie tous.
     */
    protected $proxies = '*';

    /**
     * Choisir les headers que Laravel doit faire confiance.
     */
    protected $headers = SymfonyRequest::HEADER_X_FORWARDED_FOR;
}
