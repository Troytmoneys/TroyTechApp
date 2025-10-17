import SwiftUI

struct TicketTabView: View {
    @EnvironmentObject private var session: SessionController

    var body: some View {
        TabView {
            TicketListView()
                .tabItem {
                    Label("Tickets", systemImage: "list.bullet.rectangle")
                }

            AISupportView()
                .tabItem {
                    Label("AI Support", systemImage: "brain.head.profile")
                }
        }
        .overlay(alignment: .topTrailing) {
            Menu {
                if let profile = session.profile {
                    Label(profile.username, systemImage: "person")
                }
                Button("Sign Out", role: .destructive) {
                    session.signOut()
                }
            } label: {
                Image(systemName: "person.circle")
                    .font(.title2)
                    .padding()
            }
        }
    }
}

#Preview {
    TicketTabView()
        .environmentObject(SessionController.preview)
}
