<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Config;

class ServerlessServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // Optimize for serverless environment
        if ($this->isLambdaEnvironment()) {
            $this->optimizeForLambda();
        }
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }

    /**
     * Check if we're running in AWS Lambda
     */
    private function isLambdaEnvironment(): bool
    {
        return isset($_SERVER['LAMBDA_TASK_ROOT']) || isset($_SERVER['AWS_LAMBDA_FUNCTION_NAME']);
    }

    /**
     * Apply Lambda-specific optimizations
     */
    private function optimizeForLambda(): void
    {
        // Disable session encryption for performance (use secure transmission instead)
        Config::set('session.encrypt', false);
        
        // Use file-based view cache
        Config::set('view.compiled', '/tmp/laravel_views');
        
        // Optimize cache configuration for Lambda
        if (Config::get('cache.default') === 'file') {
            Config::set('cache.stores.file.path', '/tmp/laravel_cache');
        }
        
        // Set optimal memory limits
        ini_set('memory_limit', '512M');
        
        // Optimize opcache for Lambda
        if (function_exists('opcache_get_status')) {
            ini_set('opcache.enable', '1');
            ini_set('opcache.validate_timestamps', '0');
            ini_set('opcache.max_accelerated_files', '20000');
            ini_set('opcache.memory_consumption', '256');
        }
    }
}
