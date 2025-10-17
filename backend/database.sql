CREATE TABLE users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('user','admin') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tickets (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    detail TEXT NOT NULL,
    channel ENUM('screenshot','inPerson','zoom') NOT NULL,
    requester_email VARCHAR(255) NOT NULL,
    screenshot_path VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('open','inProgress','resolved') DEFAULT 'open',
    assigned_to VARCHAR(255),
    response TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO users (username, email, password_hash, role)
VALUES
  ('troyadmin', 'troysmithson12@icloud.com', '$2y$12$HgceHBQhQAzthbKMwaxmremQtxNLOYf4FNeKNns14Mw6QUWTY8pSO', 'admin')
ON DUPLICATE KEY UPDATE email = VALUES(email);
