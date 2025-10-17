# Troy Tech Support Backend

This PHP backend provides authentication, ticket management, and AI support endpoints for the Troy Tech iOS application.

## Requirements

- PHP 8.1+
- Composer (optional for autoloading; scripts here use manual includes)
- MySQL 8+
- cURL extension enabled in PHP

## Setup

1. Copy `backend/config/config.php` and adjust the database credentials and secrets:
   - `token_secret` must be a long, random string.
   - Set `OPENROUTER_API_KEY` in your environment with a valid key.
2. Create the database schema:

   ```sh
   mysql -u root -p < backend/database.sql
   ```

3. Configure your web server (Apache, Nginx, or PHP built-in) to serve the `backend/api` directory. For development you can run:

   ```sh
   php -S 0.0.0.0:8080 -t backend/api
   ```

   Uploaded screenshots are stored under `backend/storage/uploads`. Expose them by creating a symlink so they are reachable via `/uploads`:

   ```sh
   ln -s ../storage/uploads backend/api/uploads
   ```

4. Ensure the upload directory is writable by the web server:

   ```sh
   chmod -R 775 backend/storage/uploads
   ```

## Endpoints

| Endpoint | Description |
| --- | --- |
| `POST /register.php` | Create a new user. Body: `{ "username", "email", "password" }` |
| `POST /login.php` | Authenticate with username & password. |
| `POST /apple_login.php` | Authenticate using an Apple identity token. Server attempts to infer email claim. |
| `POST /google_login.php` | Authenticate using a Google ID token (validated via Google token info endpoint). |
| `POST /tickets.php` | List tickets for authenticated user. Admins see all. |
| `POST /create_ticket.php` | Create a ticket. Includes optional `screenshotBase64`. |
| `POST /respond_ticket.php` | Admin-only ticket response. |
| `POST /ai_support.php` | Relays a question to OpenRouter and returns the AI answer. |

All endpoints expect JSON requests and return JSON responses. Authentication uses a signed token returned from the login endpoints. Include the token in the `token` field of subsequent requests.

## Notes

- The Google and Apple integrations rely on the mobile client to provide valid ID tokens. For production, verify tokens more robustly (e.g., signature verification, nonce checking).
- Update the allowed admin emails in `config.php` to designate administrators who can respond to tickets.
- To change the OpenRouter model, edit `config.php`'s `openrouter.model` value.
