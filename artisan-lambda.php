<?php

use Illuminate\Contracts\Console\Kernel;
use Illuminate\Foundation\Application;

define('LARAVEL_START', microtime(true));

// Register the Composer autoloader
require __DIR__.'/vendor/autoload.php';

// Bootstrap Laravel and handle the command
/** @var Application $app */
$app = require_once __DIR__.'/bootstrap/app.php';

// Laravel Lambda Bridge will handle the execution
if (isset($_SERVER['LAMBDA_TASK_ROOT'])) {
    // We're running in Lambda
    return $app;
}

// For local development, run artisan normally
$kernel = $app->make(Kernel::class);

$status = $kernel->handle(
    $input = new Symfony\Component\Console\Input\ArgvInput,
    new Symfony\Component\Console\Output\ConsoleOutput
);

$kernel->terminate($input, $status);

exit($status);
