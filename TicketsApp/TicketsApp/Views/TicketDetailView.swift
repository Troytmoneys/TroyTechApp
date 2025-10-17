import SwiftUI

struct TicketDetailView: View {
    @EnvironmentObject private var session: SessionController
    @State private var ticket: Ticket
    @State private var showResponseSheet = false
    @State private var errorMessage: String?

    var onUpdate: (Ticket) -> Void

    init(ticket: Ticket, onUpdate: @escaping (Ticket) -> Void) {
        self._ticket = State(initialValue: ticket)
        self.onUpdate = onUpdate
    }

    var body: some View {
        Form {
            Section("Details") {
                Text(ticket.title)
                    .font(.title3.bold())
                Text(ticket.detail)
                Label(ticket.channel.displayName, systemImage: "video")
                Label(ticket.status.displayName, systemImage: "checkmark.seal")
                if let response = ticket.response {
                    LabeledContent("Response") {
                        Text(response)
                    }
                }
            }

            Section("Requester") {
                Label(ticket.requesterEmail, systemImage: "envelope")
                if let assignedTo = ticket.assignedTo {
                    Label("Assigned to \(assignedTo)", systemImage: "person.fill")
                }
            }

            if let url = ticket.screenshotURL {
                Section("Screenshot") {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxHeight: 220)
                }
            }
        }
        .navigationTitle("Ticket #\(ticket.id)")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Respond") {
                    showResponseSheet = true
                }
                .disabled(!session.profile.map { $0.role == .admin } ?? true)
            }
        }
        .sheet(isPresented: $showResponseSheet) {
            ResponseComposerView { message in
                await respond(message: message)
            }
        }
        .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func respond(message: String) async {
        do {
            let request = TicketResponseRequest(ticketId: ticket.id, message: message)
            let updated = try await session.respondToTicket(request)
            ticket = updated
            onUpdate(updated)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct ResponseComposerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var message = ""
    var onSubmit: (String) async -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Response") {
                    TextEditor(text: $message)
                        .frame(height: 180)
                }
            }
            .navigationTitle("Respond to Ticket")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        Task {
                            await onSubmit(message)
                            dismiss()
                        }
                    }
                    .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    TicketDetailView(ticket: Ticket(id: 1, title: "Example", detail: "Example detail", channel: .screenshot, screenshotPath: nil, createdAt: Date(), status: .open, requesterEmail: "user@example.com", assignedTo: nil, response: nil)) { _ in }
        .environmentObject(SessionController.preview)
}
