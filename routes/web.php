<?php

use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::get('/', function () {
    return Inertia::render('welcome');
})->name('home');

// Environment info display route
Route::get('/env-info', function () {
    return response()->view('env-info', [
        'app_env' => config('app.env'),
        'app_name' => config('app.name'),
        'app_debug' => config('app.debug'),
        'app_url' => config('app.url'),
        'db_connection' => config('database.default'),
        'cache_driver' => config('cache.default'),
        'session_driver' => config('session.driver'),
        'is_lambda' => isset($_SERVER['LAMBDA_TASK_ROOT']),
        'php_version' => PHP_VERSION,
        'laravel_version' => app()->version(),
        'environment_type' => app()->environment(),
    ]);
})->name('env.info');

Route::get('/serverless-test', function () {
    return response()->json([
        'message' => 'Serverless test endpoint working!',
        'environment' => app()->environment(),
        'timestamp' => now()->toISOString(),
        'is_lambda' => isset($_SERVER['LAMBDA_TASK_ROOT']),
        'php_version' => PHP_VERSION,
        'laravel_version' => app()->version(),
    ]);
})->name('serverless.test');

Route::get('/aws-test', function () {
    try {
        // Create S3 client configured for LocalStack
        $s3Client = new \Aws\S3\S3Client([
            'version' => 'latest',
            'region' => config('filesystems.disks.s3.region', 'us-east-1'),
            'credentials' => [
                'key' => config('filesystems.disks.s3.key', 'test'),
                'secret' => config('filesystems.disks.s3.secret', 'test'),
            ],
            'endpoint' => config('filesystems.disks.s3.endpoint'),
            'use_path_style_endpoint' => true,
            'http' => [
                'verify' => false,
            ],
        ]);

        $bucketName = config('filesystems.disks.s3.bucket', 'laravel-serverless-local');
        
        // Test bucket operations
        $buckets = $s3Client->listBuckets();
        
        // Try to create bucket if it doesn't exist
        $bucketExists = false;
        foreach ($buckets['Buckets'] as $bucket) {
            if ($bucket['Name'] === $bucketName) {
                $bucketExists = true;
                break;
            }
        }
        
        if (!$bucketExists) {
            $s3Client->createBucket(['Bucket' => $bucketName]);
        }
        
        // Test file upload
        $testContent = 'Hello from Laravel Serverless Environment - ' . now()->toISOString();
        $key = 'test-files/serverless-test-' . time() . '.txt';
        
        $s3Client->putObject([
            'Bucket' => $bucketName,
            'Key' => $key,
            'Body' => $testContent,
            'ContentType' => 'text/plain',
        ]);
        
        // Test file download
        $result = $s3Client->getObject([
            'Bucket' => $bucketName,
            'Key' => $key,
        ]);
        
        $downloadedContent = (string) $result['Body'];
        
        return response()->json([
            'message' => 'AWS S3 LocalStack integration working!',
            'environment' => app()->environment(),
            'timestamp' => now()->toISOString(),
            'bucket_name' => $bucketName,
            'endpoint' => config('filesystems.disks.s3.endpoint'),
            'test_file_key' => $key,
            'uploaded_content' => $testContent,
            'downloaded_content' => $downloadedContent,
            'content_match' => $testContent === $downloadedContent,
            's3_config' => [
                'region' => config('filesystems.disks.s3.region'),
                'endpoint' => config('filesystems.disks.s3.endpoint'),
                'bucket' => $bucketName,
            ],
        ]);
        
    } catch (\Exception $e) {
        return response()->json([
            'error' => 'AWS S3 test failed',
            'message' => $e->getMessage(),
            'environment' => app()->environment(),
            'timestamp' => now()->toISOString(),
            's3_config' => [
                'region' => config('filesystems.disks.s3.region'),
                'endpoint' => config('filesystems.disks.s3.endpoint'),
                'bucket' => config('filesystems.disks.s3.bucket'),
            ],
        ], 500);
    }
})->name('aws.test');

Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('dashboard', function () {
        return Inertia::render('dashboard');
    })->name('dashboard');
});

require __DIR__.'/settings.php';
require __DIR__.'/auth.php';
