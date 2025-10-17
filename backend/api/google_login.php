<?php

require __DIR__ . '/bootstrap.php';

try {
    $data = parse_json_body();
    require_fields($data, ['idToken']);

    $payload = validate_google_token($data['idToken']);
    $email = $payload['email'] ?? null;
    if (!$email) {
        throw new RuntimeException('Google token missing email claim.');
    }

    $response = $auth->authenticateWithIdentityToken($email);
    json_response($response);
} catch (Throwable $e) {
    json_response(['error' => $e->getMessage()], 401);
}

function validate_google_token(string $token): array
{
    $response = file_get_contents('https://oauth2.googleapis.com/tokeninfo?id_token=' . urlencode($token));
    if ($response === false) {
        throw new RuntimeException('Unable to validate Google token.');
    }

    $data = json_decode($response, true);
    if (!is_array($data) || isset($data['error_description'])) {
        throw new RuntimeException($data['error_description'] ?? 'Invalid Google token.');
    }

    return $data;
}
