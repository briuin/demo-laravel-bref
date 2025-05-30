<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Environment Information - {{ $app_name }}</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 2rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
        }
        .container {
            background: white;
            border-radius: 12px;
            padding: 2rem;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        }
        h1 {
            color: #4a5568;
            text-align: center;
            margin-bottom: 2rem;
            font-size: 2.5rem;
        }
        .env-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        .env-card {
            background: #f7fafc;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 1.5rem;
        }
        .env-label {
            font-weight: 600;
            color: #2d3748;
            font-size: 0.875rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 0.5rem;
        }
        .env-value {
            font-size: 1.25rem;
            color: #4a5568;
            background: white;
            padding: 0.75rem;
            border-radius: 4px;
            border: 1px solid #e2e8f0;
            font-family: 'Monaco', 'Menlo', monospace;
        }
        .env-value.highlight {
            background: #edf2f7;
            color: #2b6cb0;
            font-weight: 600;
        }
        .status-badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.875rem;
            font-weight: 600;
            text-transform: uppercase;
        }
        .status-local {
            background: #fef5e7;
            color: #744210;
        }
        .status-production {
            background: #fed7e2;
            color: #97266d;
        }
        .status-debug-on {
            background: #e6fffa;
            color: #065f46;
        }
        .status-debug-off {
            background: #fee2e2;
            color: #991b1b;
        }
        .lambda-indicator {
            text-align: center;
            padding: 1rem;
            border-radius: 8px;
            margin-top: 1rem;
        }
        .lambda-yes {
            background: #dcfce7;
            color: #166534;
        }
        .lambda-no {
            background: #fef3c7;
            color: #92400e;
        }
        .back-link {
            display: inline-block;
            margin-top: 2rem;
            padding: 0.75rem 1.5rem;
            background: #4f46e5;
            color: white;
            text-decoration: none;
            border-radius: 6px;
            font-weight: 500;
            transition: background 0.2s;
        }
        .back-link:hover {
            background: #4338ca;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔧 Environment Information</h1>
        
        <div class="env-grid">
            <div class="env-card">
                <div class="env-label">Application Environment</div>
                <div class="env-value highlight">
                    {{ $app_env }}
                    <span class="status-badge {{ $app_env === 'local' ? 'status-local' : 'status-production' }}">
                        {{ $app_env }}
                    </span>
                </div>
            </div>

            <div class="env-card">
                <div class="env-label">Application Name</div>
                <div class="env-value">{{ $app_name }}</div>
            </div>

            <div class="env-card">
                <div class="env-label">Debug Mode</div>
                <div class="env-value">
                    {{ $app_debug ? 'Enabled' : 'Disabled' }}
                    <span class="status-badge {{ $app_debug ? 'status-debug-on' : 'status-debug-off' }}">
                        {{ $app_debug ? 'ON' : 'OFF' }}
                    </span>
                </div>
            </div>

            <div class="env-card">
                <div class="env-label">Application URL</div>
                <div class="env-value">{{ $app_url }}</div>
            </div>

            <div class="env-card">
                <div class="env-label">Database Connection</div>
                <div class="env-value">{{ $db_connection }}</div>
            </div>

            <div class="env-card">
                <div class="env-label">Cache Driver</div>
                <div class="env-value">{{ $cache_driver }}</div>
            </div>

            <div class="env-card">
                <div class="env-label">Session Driver</div>
                <div class="env-value">{{ $session_driver }}</div>
            </div>

            <div class="env-card">
                <div class="env-label">PHP Version</div>
                <div class="env-value">{{ $php_version }}</div>
            </div>

            <div class="env-card">
                <div class="env-label">Laravel Version</div>
                <div class="env-value">{{ $laravel_version }}</div>
            </div>
        </div>

        <div class="lambda-indicator {{ $is_lambda ? 'lambda-yes' : 'lambda-no' }}">
            <strong>{{ $is_lambda ? '🚀 Running in AWS Lambda Environment' : '💻 Running in Local Environment' }}</strong>
        </div>

        <div style="text-align: center;">
            <a href="/" class="back-link">← Back to Home</a>
        </div>
    </div>
</body>
</html>
