import SwiftUI

struct TicketListView: View {
    @EnvironmentObject private var session: SessionController
    @State private var tickets: [Ticket] = []
    @State private var showNewTicket = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if tickets.isEmpty {
                    ContentUnavailableView("No Tickets", systemImage: "ticket", description: Text("Create your first ticket to get started."))
                } else {
                    List(tickets) { ticket in
                        NavigationLink(value: ticket) {
                            TicketRow(ticket: ticket)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Tickets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewTicket = true
                    } label: {
                        Label("New Ticket", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewTicket) {
                TicketComposerView { request in
                    await createTicket(request)
                }
            }
            .task(id: session.state) {
                await loadTickets()
            }
            .refreshable {
                await loadTickets()
            }
            .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .navigationDestination(for: Ticket.self) { ticket in
                TicketDetailView(ticket: ticket, onUpdate: { updated in
                    if let index = tickets.firstIndex(of: ticket) {
                        tickets[index] = updated
                    }
                })
            }
        }
    }

    private func loadTickets() async {
        guard session.isAuthenticated else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            tickets = try await session.fetchTickets()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func createTicket(_ request: TicketCreationRequest) async -> String? {
        do {
            let ticket = try await session.createTicket(request)
            tickets.insert(ticket, at: 0)
            return nil
        } catch {
            errorMessage = error.localizedDescription
            return error.localizedDescription
        }
    }
}

private struct TicketRow: View {
    let ticket: Ticket

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(ticket.title)
                .font(.headline)
            Text(ticket.detail)
                .lineLimit(2)
                .foregroundStyle(.secondary)
            HStack {
                Label(ticket.status.displayName, systemImage: "checkmark.seal")
                Label(ticket.channel.displayName, systemImage: "video")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TicketListView()
        .environmentObject(SessionController.preview)
}
