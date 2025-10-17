import SwiftUI

struct RegistrationView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionController

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var showError = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Account")) {
                    TextField("Username", text: $username)
                        .textContentType(.username)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .emailKeyboard()
                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                }
            }
            .navigationTitle("Create Account")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Register", action: register)
                        .disabled(!isFormValid || session.state == .loading)
                }
            }
            .alert("Registration Failed", isPresented: $showError, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text(errorMessage)
            })
        }
    }

    private var isFormValid: Bool {
        !username.isEmpty && email.contains("@") && password.count >= 8 && password == confirmPassword
    }

    private func register() {
        Task {
            await session.register(username: username, email: email, password: password)
            if case .failure(let message) = session.state {
                await MainActor.run {
                    errorMessage = message
                    showError = true
                }
            } else {
                await MainActor.run {
                    dismiss()
                }
            }
        }
    }
}

#if os(iOS)
private extension View {
    func emailKeyboard() -> some View {
        keyboardType(.emailAddress)
    }
}
#else
private extension View {
    func emailKeyboard() -> some View {
        self
    }
}
#endif

#Preview {
    RegistrationView()
        .environmentObject(SessionController.preview)
}
