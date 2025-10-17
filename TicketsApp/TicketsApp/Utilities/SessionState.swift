import Foundation

enum SessionState: Equatable {
    case unauthenticated
    case loading
    case authenticated(token: String)
    case failure(String)
}
