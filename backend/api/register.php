<?php

require __DIR__ . '/bootstrap.php';

try {
    $data = parse_json_body();
    require_fields($data, ['username', 'email', 'password']);

    $response = $auth->register($data['username'], $data['email'], $data['password']);
    json_response($response);
} catch (Throwable $e) {
    json_response(['error' => $e->getMessage()], 400);
}
