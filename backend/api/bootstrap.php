<?php

declare(strict_types=1);

require_once __DIR__ . '/../lib/Database.php';
require_once __DIR__ . '/../lib/Auth.php';
require_once __DIR__ . '/../lib/TicketRepository.php';
require_once __DIR__ . '/../lib/Storage.php';
require_once __DIR__ . '/../lib/OpenRouterClient.php';

$config = require __DIR__ . '/../config/config.php';
$db = new Database($config['db']);
$pdo = $db->pdo();
$auth = new Auth($pdo, $config['auth']);
$tickets = new TicketRepository($pdo);
$storage = new Storage($config['storage']['path']);
$aiClient = new OpenRouterClient($config['openrouter']);

function json_response($data, int $status = 200): void
{
    http_response_code($status);
    header('Content-Type: application/json');
    echo json_encode($data);
    exit;
}

function parse_json_body(): array
{
    $input = file_get_contents('php://input');
    if (!$input) {
        return [];
    }
    $data = json_decode($input, true);
    if (!is_array($data)) {
        throw new RuntimeException('Invalid JSON payload.');
    }
    return $data;
}

function require_fields(array $data, array $fields): void
{
    foreach ($fields as $field) {
        if (!array_key_exists($field, $data) || $data[$field] === '') {
            throw new RuntimeException('Missing required field: ' . $field);
        }
    }
}
