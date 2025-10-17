<?php

require __DIR__ . '/bootstrap.php';

try {
    $data = parse_json_body();
    require_fields($data, ['token', 'ticketId', 'message']);

    $user = $auth->validateToken($data['token']);
    if ($user['role'] !== 'admin') {
        throw new RuntimeException('Only admins can respond to tickets.');
    }

    $ticket = $tickets->respond((int) $data['ticketId'], $data['message'], $user);
    json_response($ticket);
} catch (Throwable $e) {
    json_response(['error' => $e->getMessage()], 403);
}
