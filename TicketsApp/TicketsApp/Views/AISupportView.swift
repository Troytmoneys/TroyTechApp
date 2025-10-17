import SwiftUI

struct AISupportView: View {
    @EnvironmentObject private var session: SessionController
    @State private var prompt = ""
    @State private var responseText: String = "Ask Troy Tech AI for help with your issue."
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                ScrollView {
                    Text(responseText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }

                Spacer(minLength: 16)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Ask a question")
                        .font(.headline)
                    TextEditor(text: $prompt)
                        .frame(height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
                    Button(action: sendQuestion) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Send to AI")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }
            }
            .padding()
            .navigationTitle("AI Support")
            .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func sendQuestion() {
        isLoading = true
        Task {
            do {
                let answer = try await session.requestAISupport(question: prompt)
                await MainActor.run {
                    responseText = answer
                    prompt = ""
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

#Preview {
    AISupportView()
        .environmentObject(SessionController.preview)
}
