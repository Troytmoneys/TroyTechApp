<?php

require __DIR__ . '/bootstrap.php';

try {
    $data = parse_json_body();
    require_fields($data, ['token', 'title', 'detail', 'channel', 'requesterEmail']);

    $user = $auth->validateToken($data['token']);
    $filename = $storage->saveBase64Screenshot($data['screenshotBase64'] ?? null);
    if ($filename) {
        $data['screenshot_path'] = $filename;
    }

    $ticket = $tickets->create($data, $user);
    json_response($ticket, 201);
} catch (Throwable $e) {
    json_response(['error' => $e->getMessage()], 400);
}
