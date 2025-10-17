<?php
return [
    'db' => [
        'dsn' => 'mysql:host=127.0.0.1;dbname=troytech;charset=utf8mb4',
        'username' => 'troytech_user',
        'password' => 'change-me',
    ],
    'auth' => [
        'admin_emails' => [
            'troysmithson12@icloud.com',
            'troytroytroytroy333@gmail.com'
        ],
        'token_secret' => 'replace-with-a-secure-random-secret',
        'token_ttl' => 604800
    ],
    'storage' => [
        'path' => __DIR__ . '/../storage/uploads'
    ],
    'openrouter' => [
        'api_key' => getenv('OPENROUTER_API_KEY') ?: '',
        'base_url' => 'https://openrouter.ai/api/v1/chat/completions',
        'model' => 'openai/gpt-4o-mini'
    ]
];
