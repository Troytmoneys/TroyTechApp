<?php

require __DIR__ . '/bootstrap.php';

try {
    $data = parse_json_body();
    require_fields($data, ['username', 'password']);

    $response = $auth->authenticate($data['username'], $data['password']);
    json_response($response);
} catch (Throwable $e) {
    json_response(['error' => $e->getMessage()], 401);
}
