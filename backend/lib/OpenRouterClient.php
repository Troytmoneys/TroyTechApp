<?php

class OpenRouterClient
{
    private string $apiKey;
    private string $baseUrl;
    private string $model;

    public function __construct(array $config)
    {
        $this->apiKey = $config['api_key'];
        $this->baseUrl = $config['base_url'];
        $this->model = $config['model'];
    }

    public function ask(string $prompt): string
    {
        if (empty($this->apiKey)) {
            throw new RuntimeException('OpenRouter API key is not configured.');
        }

        $payload = [
            'model' => $this->model,
            'messages' => [
                ['role' => 'system', 'content' => 'You are Troy Tech AI, a friendly IT assistant.'],
                ['role' => 'user', 'content' => $prompt]
            ]
        ];

        $ch = curl_init($this->baseUrl);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $this->apiKey,
            'Content-Type: application/json'
        ]);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));

        $result = curl_exec($ch);
        if ($result === false) {
            throw new RuntimeException('Failed to contact OpenRouter: ' . curl_error($ch));
        }

        $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($status < 200 || $status >= 300) {
            throw new RuntimeException('OpenRouter API returned status ' . $status . ': ' . $result);
        }

        $data = json_decode($result, true);
        if (!$data || empty($data['choices'][0]['message']['content'])) {
            throw new RuntimeException('Unexpected OpenRouter response.');
        }

        return $data['choices'][0]['message']['content'];
    }
}
