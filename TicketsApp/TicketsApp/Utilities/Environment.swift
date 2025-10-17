import Foundation

enum Environment {
    static var serverBaseURL: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "ServerBaseURL") as? String,
              let url = URL(string: urlString) else {
            return URL(string: "http://localhost:8080/api/")!
        }
        return url
    }

    static var serverRootURL: URL {
        var components = URLComponents()
        components.scheme = serverBaseURL.scheme
        components.host = serverBaseURL.host
        components.port = serverBaseURL.port
        return components.url ?? serverBaseURL
    }

    static func url(for path: String) -> URL {
        if let url = URL(string: path), url.scheme != nil {
            return url
        }
        var sanitized = path
        if sanitized.hasPrefix("/") {
            sanitized.removeFirst()
        }
        return serverRootURL.appendingPathComponent(sanitized)
    }

    static var openRouterAPIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "OpenRouterAPIKey") as? String else {
            return ""
        }
        return key
    }
}
