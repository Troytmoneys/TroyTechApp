<?php

class TicketRepository
{
    private PDO $pdo;

    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }

    public function listForUser(array $user): array
    {
        if ($user['role'] === 'admin') {
            $stmt = $this->pdo->query('SELECT * FROM tickets ORDER BY created_at DESC');
        } else {
            $stmt = $this->pdo->prepare('SELECT * FROM tickets WHERE requester_email = :email ORDER BY created_at DESC');
            $stmt->execute([':email' => $user['email']]);
        }

        return array_map([$this, 'mapTicket'], $stmt->fetchAll());
    }

    public function create(array $data, array $user): array
    {
        $stmt = $this->pdo->prepare('INSERT INTO tickets (title, detail, channel, requester_email, screenshot_path, created_at, status) VALUES (:title, :detail, :channel, :requester_email, :screenshot_path, NOW(), :status)');
        $stmt->execute([
            ':title' => $data['title'],
            ':detail' => $data['detail'],
            ':channel' => $data['channel'],
            ':requester_email' => $data['requesterEmail'],
            ':screenshot_path' => $data['screenshot_path'] ?? null,
            ':status' => 'open',
        ]);

        return $this->find((int) $this->pdo->lastInsertId());
    }

    public function respond(int $ticketId, string $message, array $user): array
    {
        $stmt = $this->pdo->prepare('UPDATE tickets SET response = :message, assigned_to = :assigned_to, status = :status WHERE id = :id');
        $stmt->execute([
            ':message' => $message,
            ':assigned_to' => $user['email'],
            ':status' => 'inProgress',
            ':id' => $ticketId,
        ]);

        return $this->find($ticketId);
    }

    public function find(int $ticketId): array
    {
        $stmt = $this->pdo->prepare('SELECT * FROM tickets WHERE id = :id');
        $stmt->execute([':id' => $ticketId]);
        $ticket = $stmt->fetch();
        if (!$ticket) {
            throw new RuntimeException('Ticket not found.');
        }
        return $this->mapTicket($ticket);
    }

    private function mapTicket(array $ticket): array
    {
        $path = $ticket['screenshot_path'];
        if ($path) {
            $path = 'uploads/' . ltrim($path, '/');
        }

        return [
            'id' => (int) $ticket['id'],
            'title' => $ticket['title'],
            'detail' => $ticket['detail'],
            'channel' => $ticket['channel'],
            'screenshotPath' => $path,
            'createdAt' => date(DATE_ATOM, strtotime($ticket['created_at'])),
            'status' => $ticket['status'],
            'requesterEmail' => $ticket['requester_email'],
            'assignedTo' => $ticket['assigned_to'],
            'response' => $ticket['response'],
        ];
    }
}
