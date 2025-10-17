import Foundation

enum UserRole: String, Codable {
    case user
    case admin
}

struct UserProfile: Codable, Identifiable {
    let id: Int
    let username: String
    let email: String
    let role: UserRole
}

struct AuthenticationResponse: Codable {
    let token: String
    let profile: UserProfile
}

struct SessionSnapshot: Codable {
    let token: String
    let profile: UserProfile
}
