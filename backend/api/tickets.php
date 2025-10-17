<?php

require __DIR__ . '/bootstrap.php';

try {
    $data = parse_json_body();
    require_fields($data, ['token']);

    $user = $auth->validateToken($data['token']);
    $items = $tickets->listForUser($user);

    json_response(['tickets' => $items]);
} catch (Throwable $e) {
    json_response(['error' => $e->getMessage()], 401);
}
