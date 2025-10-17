import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @EnvironmentObject private var session: SessionController
    @State private var showRegistration = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "ticket")
                    .font(.system(size: 64))
                    .padding(.top, 32)

                Text("Troy Tech Support")
                    .font(.largeTitle.bold())

                LoginForm(showError: $showError, errorMessage: $errorMessage)

                Divider()
                    .padding(.vertical)

                GoogleSignInButton {
                    Task {
                        await performGoogleSignIn()
                    }
                }

                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.email, .fullName]
                } onCompletion: { result in
                    switch result {
                    case .success(let auth):
                        if case let .appleID(credential) = auth.credential,
                           let tokenData = credential.identityToken,
                           let token = String(data: tokenData, encoding: .utf8) {
                            Task {
                                await session.authenticateWithApple(token: token, email: credential.email)
                            }
                        } else {
                            present(error: "Unable to read Apple ID credential.")
                        }
                    case .failure(let error):
                        present(error: error.localizedDescription)
                    }
                }
                .frame(height: 46)
                .signInWithAppleButtonStyle(.black)

                Button("Create an account") {
                    showRegistration.toggle()
                }
                .padding(.top)

                Spacer()
            }
            .padding()
            .sheet(isPresented: $showRegistration) {
                RegistrationView()
            }
            .alert("Sign In Failed", isPresented: $showError, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text(errorMessage)
            })
        }
    }

    private func performGoogleSignIn() async {
        do {
            let token = try await GoogleSignInHelper.shared.signIn()
            await session.authenticateWithGoogle(token: token)
        } catch {
            present(error: error.localizedDescription)
        }
    }

    private func present(error message: String) {
        errorMessage = message
        showError = true
    }
}

private struct LoginForm: View {
    @EnvironmentObject private var session: SessionController

    @State private var username = ""
    @State private var password = ""

    @Binding var showError: Bool
    @Binding var errorMessage: String

    var body: some View {
        VStack(spacing: 16) {
            TextField("Username", text: $username)
                .textContentType(.username)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textContentType(.password)
                .textFieldStyle(.roundedBorder)

            Button(action: signIn) {
                if case .loading = session.state {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Sign In")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(username.isEmpty || password.isEmpty || (session.state == .loading))
        }
    }

    private func signIn() {
        Task {
            await session.authenticate(username: username, password: password)
            if case .failure(let message) = session.state {
                await MainActor.run {
                    errorMessage = message
                    showError = true
                }
            }
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(SessionController.preview)
}
