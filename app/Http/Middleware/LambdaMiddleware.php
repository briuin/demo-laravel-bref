<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class LambdaMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Add Lambda-specific headers
        if ($this->isLambdaEnvironment()) {
            $this->addLambdaHeaders($request);
        }

        $response = $next($request);

        // Add Lambda-specific response headers
        if ($this->isLambdaEnvironment()) {
            $this->addLambdaResponseHeaders($response);
        }

        return $response;
    }

    /**
     * Check if we're running in AWS Lambda
     */
    private function isLambdaEnvironment(): bool
    {
        return isset($_SERVER['LAMBDA_TASK_ROOT']) || isset($_SERVER['AWS_LAMBDA_FUNCTION_NAME']);
    }

    /**
     * Add Lambda-specific request headers
     */
    private function addLambdaHeaders(Request $request): void
    {
        // Add AWS request ID for tracing
        if (isset($_SERVER['AWS_REQUEST_ID'])) {
            $request->headers->set('X-AWS-Request-ID', $_SERVER['AWS_REQUEST_ID']);
        }

        // Add Lambda context information
        if (isset($_SERVER['AWS_LAMBDA_FUNCTION_NAME'])) {
            $request->headers->set('X-Lambda-Function-Name', $_SERVER['AWS_LAMBDA_FUNCTION_NAME']);
        }

        if (isset($_SERVER['AWS_LAMBDA_FUNCTION_VERSION'])) {
            $request->headers->set('X-Lambda-Function-Version', $_SERVER['AWS_LAMBDA_FUNCTION_VERSION']);
        }
    }

    /**
     * Add Lambda-specific response headers
     */
    private function addLambdaResponseHeaders(Response $response): void
    {
        // Add execution environment info
        $response->headers->set('X-Powered-By', 'Laravel-Serverless');
        
        // Add AWS request ID if available
        if (isset($_SERVER['AWS_REQUEST_ID'])) {
            $response->headers->set('X-AWS-Request-ID', $_SERVER['AWS_REQUEST_ID']);
        }

        // Add cache control for static assets
        if ($this->isStaticAsset($response)) {
            $response->headers->set('Cache-Control', 'public, max-age=31536000, immutable');
        }
    }

    /**
     * Check if the response is for a static asset
     */
    private function isStaticAsset(Response $response): bool
    {
        $contentType = $response->headers->get('Content-Type', '');
        
        return str_contains($contentType, 'css') ||
               str_contains($contentType, 'javascript') ||
               str_contains($contentType, 'image/') ||
               str_contains($contentType, 'font/');
    }
}
