<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Lambda-specific configurations
    |--------------------------------------------------------------------------
    |
    | These configurations are optimized for AWS Lambda execution
    |
    */

    'memory_limit' => env('LAMBDA_MEMORY_LIMIT', '512M'),
    
    'tmp_storage' => '/tmp',
    
    'optimizations' => [
        'opcache' => true,
        'view_cache' => true,
        'config_cache' => true,
        'route_cache' => true,
    ],
    
    /*
    |--------------------------------------------------------------------------
    | Warm-up configuration
    |--------------------------------------------------------------------------
    |
    | These settings help with Lambda cold starts
    |
    */
    
    'warmup' => [
        'enabled' => env('LAMBDA_WARMUP_ENABLED', false),
        'source' => env('LAMBDA_WARMUP_SOURCE', 'serverless-warmup-plugin'),
    ],
    
    /*
    |--------------------------------------------------------------------------
    | Logging configuration for Lambda
    |--------------------------------------------------------------------------
    */
    
    'logging' => [
        'level' => env('LAMBDA_LOG_LEVEL', 'info'),
        'max_files' => 5,
        'max_file_size' => '10MB',
    ],
];
