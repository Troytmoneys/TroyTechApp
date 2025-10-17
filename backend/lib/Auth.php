<?php

class Auth
{
    private PDO $pdo;
    private array $config;

    public function __construct(PDO $pdo, array $config)
    {
        $this->pdo = $pdo;
        $this->config = $config;
    }

    public function register(string $username, string $email, string $password): array
    {
        $role = $this->isAdmin($email) ? 'admin' : 'user';
        $hash = password_hash($password, PASSWORD_ARGON2ID);
        $stmt = $this->pdo->prepare('INSERT INTO users (username, email, password_hash, role) VALUES (:username, :email, :hash, :role)');
        $stmt->execute([
            ':username' => $username,
            ':email' => $email,
            ':hash' => $hash,
            ':role' => $role,
        ]);

        return $this->authenticate($username, $password);
    }

    public function authenticate(string $username, string $password): array
    {
        $stmt = $this->pdo->prepare('SELECT * FROM users WHERE username = :username LIMIT 1');
        $stmt->execute([':username' => $username]);
        $user = $stmt->fetch();

        if (!$user || !password_verify($password, $user['password_hash'])) {
            throw new RuntimeException('Invalid credentials.');
        }

        return $this->tokenResponse($user);
    }

    public function authenticateWithIdentityToken(string $email): array
    {
        $stmt = $this->pdo->prepare('SELECT * FROM users WHERE email = :email LIMIT 1');
        $stmt->execute([':email' => $email]);
        $user = $stmt->fetch();

        if (!$user) {
            $username = explode('@', $email)[0] . random_int(1000, 9999);
            $stmt = $this->pdo->prepare('INSERT INTO users (username, email, password_hash, role) VALUES (:username, :email, :hash, :role)');
            $stmt->execute([
                ':username' => $username,
                ':email' => $email,
                ':hash' => password_hash(bin2hex(random_bytes(16)), PASSWORD_ARGON2ID),
                ':role' => $this->isAdmin($email) ? 'admin' : 'user',
            ]);
            $user = [
                'id' => $this->pdo->lastInsertId(),
                'username' => $username,
                'email' => $email,
                'role' => $this->isAdmin($email) ? 'admin' : 'user',
            ];
        }

        return $this->tokenResponse($user);
    }

    public function validateToken(string $token): array
    {
        [$payload, $signature] = explode('.', $token);
        $expected = hash_hmac('sha256', $payload, $this->config['token_secret']);
        if (!hash_equals($expected, $signature)) {
            throw new RuntimeException('Invalid token.');
        }

        $data = json_decode(base64_decode($payload), true);
        if (!$data || $data['exp'] < time()) {
            throw new RuntimeException('Token expired.');
        }

        return $data;
    }

    private function tokenResponse(array $user): array
    {
        $role = $this->isAdmin($user['email']) ? 'admin' : ($user['role'] ?? 'user');
        $payload = [
            'id' => (int) $user['id'],
            'username' => $user['username'],
            'email' => $user['email'],
            'role' => $role,
            'exp' => time() + $this->config['token_ttl'],
        ];
        $encoded = base64_encode(json_encode($payload));
        $signature = hash_hmac('sha256', $encoded, $this->config['token_secret']);
        return [
            'token' => $encoded . '.' . $signature,
            'profile' => [
                'id' => $payload['id'],
                'username' => $payload['username'],
                'email' => $payload['email'],
                'role' => $payload['role'],
            ],
        ];
    }

    private function isAdmin(string $email): bool
    {
        return in_array(strtolower($email), array_map('strtolower', $this->config['admin_emails']), true);
    }
}
