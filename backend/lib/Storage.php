<?php

class Storage
{
    private string $path;

    public function __construct(string $path)
    {
        $this->path = $path;
        if (!is_dir($path)) {
            mkdir($path, 0775, true);
        }
    }

    public function saveBase64Screenshot(?string $base64): ?string
    {
        if (!$base64) {
            return null;
        }

        $data = base64_decode($base64);
        if ($data === false) {
            throw new RuntimeException('Invalid screenshot data.');
        }

        $filename = uniqid('ticket_', true) . '.png';
        file_put_contents($this->path . '/' . $filename, $data);
        return $filename;
    }
}
