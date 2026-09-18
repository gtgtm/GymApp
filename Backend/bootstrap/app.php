<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->api(prepend: [
            \Illuminate\Routing\Middleware\ThrottleRequests::class.':api',
        ]);

        // SubstituteBindings resolves route-model params (e.g. {member}) and
        // by default runs in the "api" group, before our route-level
        // auth:sanctum/acting_gym middleware. That order breaks gym-scoped
        // implicit binding for super_admin: the model lookup would run
        // before the acting gym is known. Move it after auth so route
        // params are resolved once request()->user() and the acting gym
        // are both available.
        $middleware->removeFromGroup('api', \Illuminate\Routing\Middleware\SubstituteBindings::class);

        $middleware->alias([
            'role' => \App\Http\Middleware\EnsureUserHasRole::class,
            'member_limit' => \App\Http\Middleware\EnforceMemberLimit::class,
            'acting_gym' => \App\Http\Middleware\ResolveActingGym::class,
            'bindings' => \Illuminate\Routing\Middleware\SubstituteBindings::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*') || $request->expectsJson(),
        );
    })->create();
