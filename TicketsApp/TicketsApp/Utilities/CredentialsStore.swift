import Foundation

final class CredentialsStore {
    static let shared = CredentialsStore()

    private let defaults = UserDefaults.standard
    private let credentialsKey = "StoredSessionSnapshot"

    private init() {}

    func store(snapshot: SessionSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: credentialsKey)
    }

    func fetchSnapshot() -> SessionSnapshot? {
        guard let data = defaults.data(forKey: credentialsKey) else { return nil }
        return try? JSONDecoder().decode(SessionSnapshot.self, from: data)
    }

    func clear() {
        defaults.removeObject(forKey: credentialsKey)
    }
}
