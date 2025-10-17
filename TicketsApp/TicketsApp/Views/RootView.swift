import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: SessionController

    var body: some View {
        Group {
            if session.isAuthenticated {
                TicketTabView()
            } else {
                AuthenticationView()
            }
        }
        .onAppear {
            session.restoreSession()
        }
    }
}

#Preview {
    RootView()
        .environmentObject(SessionController.preview)
}
