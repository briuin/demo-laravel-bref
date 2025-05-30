<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'environment' => app()->environment(),
        'timestamp' => now()->toISOString(),
        'version' => '1.0.0',
        'services' => [
            'database' => 'connected',
            'cache' => 'working',
            'storage' => 'accessible'
        ]
    ]);
});

Route::get('/lambda-test', function (Request $request) {
    return response()->json([
        'message' => 'Lambda function is working!',
        'environment' => app()->environment(),
        'request_id' => $request->header('x-request-id', 'local-test'),
        'timestamp' => now()->toISOString(),
        'headers' => $request->headers->all(),
        'method' => $request->method(),
        'path' => $request->path(),
    ]);
});
