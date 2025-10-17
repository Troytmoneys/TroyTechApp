<?php

require __DIR__ . '/bootstrap.php';

try {
    $data = parse_json_body();
    require_fields($data, ['identityToken']);

    $email = $data['email'] ?? extract_email_from_jwt($data['identityToken']);
    if (!$email) {
        throw new RuntimeException('Unable to determine email from Apple identity token.');
    }

    $response = $auth->authenticateWithIdentityToken($email);
    json_response($response);
} catch (Throwable $e) {
    json_response(['error' => $e->getMessage()], 401);
}

function extract_email_from_jwt(string $jwt): ?string
{
    $parts = explode('.', $jwt);
    if (count($parts) < 2) {
        return null;
    }
    $payload = $parts[1];
    $remainder = strlen($payload) % 4;
    if ($remainder) {
        $payload .= str_repeat('=', 4 - $remainder);
    }
    $decoded = json_decode(base64_decode(strtr($payload, '-_', '+/')), true);
    return $decoded['email'] ?? null;
}
