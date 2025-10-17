# Troy Tech Support

This repository contains a SwiftUI iOS application and a PHP backend for managing Troy Tech support tickets. Users can register or sign in (including Sign in with Apple / Google), submit support tickets, and chat with an AI assistant powered by OpenRouter. Admins (Troy Smithson and Troy Troy) can view all tickets and respond to them.

## Contents

- `TicketsApp/` – Xcode project for the iOS client
- `backend/` – PHP REST API and database schema

## iOS App

### Requirements

- Xcode 16.2+
- iOS 17 SDK
- SwiftUI, PhotosUI, AuthenticationServices frameworks
- GoogleSignIn SDK (to be integrated in Xcode for Google auth)

### Project Structure

Open `TicketsApp/TicketsApp.xcodeproj` in Xcode. The main components are:

- `TicketsAppApp.swift` – App entry point and session bootstrap
- `Views/` – SwiftUI screens for authentication, ticket browsing, creation, and AI chat
- `ViewModels/SessionController.swift` – Authentication state and API orchestration
- `Networking/APIClient.swift` – REST client for the backend
- `Models/` – Shared data models for users and tickets
- `Utilities/` – Helpers for credential storage, environment configuration, and the (stubbed) Google sign-in bridge

After configuring the backend URL and OpenRouter key in `Info.plist`, run the app on a simulator or device. Google Sign-In requires linking the GoogleSignIn SDK and implementing token retrieval inside `GoogleSignInHelper`.

### Configuration

Update `TicketsApp/TicketsApp/SupportingFiles/Info.plist`:

- `ServerBaseURL` – Base URL pointing to your PHP API (e.g., `http://localhost:8080/api/`). The app derives asset URLs from the same host for screenshots.
- `OpenRouterAPIKey` – Optional key if you plan to call OpenRouter directly from the app (backend currently handles AI calls).

## Backend

See [`backend/README.md`](backend/README.md) for full setup instructions. The backend provides JSON endpoints for registration, authentication, ticket CRUD, and AI support.

## Running Locally

1. Start the backend API (e.g., `php -S 0.0.0.0:8080 -t backend/api`).
2. Symlink `backend/api/uploads` to `backend/storage/uploads` as described in the backend README so uploaded screenshots are accessible.
3. Update the iOS app `ServerBaseURL` to `http://localhost:8080/api/`.
4. Build and run the iOS app in Xcode 16.2+.

## Admin Access

The backend config designates `troysmithson12@icloud.com` and `troytroytroytroy333@gmail.com` as administrators. Admin users can view/respond to all tickets within the app.
