import Foundation

@MainActor
final class SessionController: ObservableObject {
    @Published private(set) var state: SessionState = .unauthenticated
    @Published var profile: UserProfile?

    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    var isAuthenticated: Bool {
        if case .authenticated = state {
            return true
        }
        return false
    }

    func restoreSession() {
        guard case .unauthenticated = state else { return }
        if let snapshot = CredentialsStore.shared.fetchSnapshot() {
            profile = snapshot.profile
            state = .authenticated(token: snapshot.token)
        }
    }

    func authenticate(username: String, password: String) async {
        state = .loading
        do {
            let response = try await apiClient.login(username: username, password: password)
            handleAuthenticationSuccess(response: response)
        } catch {
            state = .failure(error.localizedDescription)
        }
    }

    func register(username: String, email: String, password: String) async {
        state = .loading
        do {
            let response = try await apiClient.register(username: username, email: email, password: password)
            handleAuthenticationSuccess(response: response)
        } catch {
            state = .failure(error.localizedDescription)
        }
    }

    func authenticateWithApple(token: String, email: String?) async {
        state = .loading
        do {
            let response = try await apiClient.appleLogin(identityToken: token, email: email)
            handleAuthenticationSuccess(response: response)
        } catch {
            state = .failure(error.localizedDescription)
        }
    }

    func authenticateWithGoogle(token: String) async {
        state = .loading
        do {
            let response = try await apiClient.googleLogin(idToken: token)
            handleAuthenticationSuccess(response: response)
        } catch {
            state = .failure(error.localizedDescription)
        }
    }

    func signOut() {
        CredentialsStore.shared.clear()
        profile = nil
        state = .unauthenticated
    }

    func fetchTickets() async throws -> [Ticket] {
        let token = try currentToken()
        return try await apiClient.fetchTickets(token: token)
    }

    func createTicket(_ request: TicketCreationRequest) async throws -> Ticket {
        let token = try currentToken()
        return try await apiClient.createTicket(request, token: token)
    }

    func respondToTicket(_ request: TicketResponseRequest) async throws -> Ticket {
        let token = try currentToken()
        return try await apiClient.respondToTicket(request, token: token)
    }

    func requestAISupport(question: String) async throws -> String {
        let token = try currentToken()
        return try await apiClient.requestAISupport(question: question, token: token)
    }

    private func currentToken() throws -> String {
        guard case .authenticated(let token) = state else {
            throw APIError.server("Not authenticated")
        }
        return token
    }

    private func handleAuthenticationSuccess(response: AuthenticationResponse) {
        profile = response.profile
        let snapshot = SessionSnapshot(token: response.token, profile: response.profile)
        CredentialsStore.shared.store(snapshot: snapshot)
        state = .authenticated(token: response.token)
    }
}

extension SessionController {
    static let preview: SessionController = {
        let controller = SessionController(apiClient: APIClient.mock)
        let profile = UserProfile(id: 1, username: "preview", email: "preview@example.com", role: .user)
        controller.profile = profile
        controller.state = .authenticated(token: "preview-token")
        return controller
    }()
}
