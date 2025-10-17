import Foundation

actor GoogleSignInHelper {
    static let shared = GoogleSignInHelper()

    enum Error: Swift.Error, LocalizedError {
        case notImplemented

        var errorDescription: String? {
            switch self {
            case .notImplemented:
                return "Google Sign-In requires integrating the GoogleSignIn SDK in Xcode."
            }
        }
    }

    func signIn() async throws -> String {
        throw Error.notImplemented
    }
}
