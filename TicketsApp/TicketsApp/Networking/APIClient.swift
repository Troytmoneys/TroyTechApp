import Foundation

struct APIClient {
    var baseURL: URL
    var urlSession: URLSession

    init(baseURL: URL = Environment.serverBaseURL, urlSession: URLSession = .shared) {
        self.baseURL = baseURL
        self.urlSession = urlSession
    }

    func login(username: String, password: String) async throws -> AuthenticationResponse {
        let body = ["username": username, "password": password]
        return try await send(path: "login.php", body: body)
    }

    func register(username: String, email: String, password: String) async throws -> AuthenticationResponse {
        let body = ["username": username, "email": email, "password": password]
        return try await send(path: "register.php", body: body)
    }

    func appleLogin(identityToken: String, email: String?) async throws -> AuthenticationResponse {
        var body: [String: Any] = ["identityToken": identityToken]
        if let email {
            body["email"] = email
        }
        return try await send(path: "apple_login.php", body: body)
    }

    func googleLogin(idToken: String) async throws -> AuthenticationResponse {
        let body = ["idToken": idToken]
        return try await send(path: "google_login.php", body: body)
    }

    func fetchTickets(token: String) async throws -> [Ticket] {
        let response: TicketListResponse = try await send(path: "tickets.php", body: ["token": token])
        return response.tickets
    }

    func createTicket(_ request: TicketCreationRequest, token: String) async throws -> Ticket {
        return try await send(path: "create_ticket.php", body: [
            "token": token,
            "title": request.title,
            "detail": request.detail,
            "channel": request.channel.rawValue,
            "requesterEmail": request.requesterEmail,
            "screenshotBase64": request.screenshotBase64 ?? ""
        ])
    }

    func respondToTicket(_ request: TicketResponseRequest, token: String) async throws -> Ticket {
        return try await send(path: "respond_ticket.php", body: [
            "token": token,
            "ticketId": request.ticketId,
            "message": request.message
        ])
    }

    func requestAISupport(question: String, token: String) async throws -> String {
        struct AIResponse: Codable { let message: String }
        let response: AIResponse = try await send(path: "ai_support.php", body: [
            "token": token,
            "question": question
        ])
        return response.message
    }

    @discardableResult
    private func send<Response: Decodable>(path: String, body: [String: Any]) async throws -> Response {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            let message = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw APIError.server(message?.error ?? (String(data: data, encoding: .utf8) ?? "Unknown error"))
        }

        do {
            return try JSONDecoder.api.decode(Response.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}

extension APIClient {
    static let mock: APIClient = {
        let baseURL = URL(string: "https://example.com")!
        return APIClient(baseURL: baseURL, urlSession: .shared)
    }()
}

enum APIError: LocalizedError {
    case server(String)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .server(let message):
            return message
        case .decoding(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

private extension JSONDecoder {
    static let api: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

private struct ErrorResponse: Decodable {
    let error: String
}
