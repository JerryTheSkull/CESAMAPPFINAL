<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful;
use App\Http\Middleware\AdminMiddleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php', 
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        // Configuration des alias de middlewares pour Laravel 11
        $middleware->alias([
            'sanctum.frontend' => EnsureFrontendRequestsAreStateful::class,
            
            // Middlewares personnalisés
            'admin' => \App\Http\Middleware\AdminMiddleware::class,
            
            // Middlewares Spatie Permission - OBLIGATOIRES
            'role' => \Spatie\Permission\Middleware\RoleMiddleware::class,
            'permission' => \Spatie\Permission\Middleware\PermissionMiddleware::class,
            'role_or_permission' => \Spatie\Permission\Middleware\RoleOrPermissionMiddleware::class,
        ]);

        // Ajouter sanctum au groupe API
        $middleware->prependToGroup('api', 'sanctum.frontend');
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })->create();