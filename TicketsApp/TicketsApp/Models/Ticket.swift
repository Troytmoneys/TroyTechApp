import Foundation

enum SupportChannel: String, Codable, CaseIterable, Identifiable {
    case screenshot
    case inPerson
    case zoom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .screenshot:
            return "Screenshot"
        case .inPerson:
            return "In Person"
        case .zoom:
            return "Zoom"
        }
    }
}

struct Ticket: Codable, Identifiable, Hashable {
    let id: Int
    var title: String
    var detail: String
    var channel: SupportChannel
    var screenshotPath: String?
    var createdAt: Date
    var status: TicketStatus
    var requesterEmail: String
    var assignedTo: String?
    var response: String?

    var screenshotURL: URL? {
        guard let screenshotPath else { return nil }
        return Environment.url(for: screenshotPath)
    }
}

enum TicketStatus: String, Codable, CaseIterable, Identifiable {
    case open
    case inProgress
    case resolved

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .open: return "Open"
        case .inProgress: return "In Progress"
        case .resolved: return "Resolved"
        }
    }
}

struct TicketListResponse: Codable {
    let tickets: [Ticket]
}

struct TicketCreationRequest: Codable {
    let title: String
    let detail: String
    let channel: SupportChannel
    let requesterEmail: String
    let screenshotBase64: String?
}

struct TicketResponseRequest: Codable {
    let ticketId: Int
    let message: String
}
