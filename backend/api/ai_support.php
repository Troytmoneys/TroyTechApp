<?php

require __DIR__ . '/bootstrap.php';

try {
    $data = parse_json_body();
    require_fields($data, ['token', 'question']);

    $auth->validateToken($data['token']);
    $answer = $aiClient->ask($data['question']);

    json_response(['message' => $answer]);
} catch (Throwable $e) {
    json_response(['error' => $e->getMessage()], 400);
}
