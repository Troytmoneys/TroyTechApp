import SwiftUI
import PhotosUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct TicketComposerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var detail = ""
    @State private var channel: SupportChannel = .screenshot
    @State private var requesterEmail = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var isSaving = false
    @State private var errorMessage: String?

    var onCreate: (TicketCreationRequest) async -> String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Issue") {
                    TextField("Subject", text: $title)
                    Picker("Support Type", selection: $channel) {
                        ForEach(SupportChannel.allCases) { channel in
                            Text(channel.displayName).tag(channel)
                        }
                    }
                    TextEditor(text: $detail)
                        .frame(height: 120)
                }

                Section("Requester") {
                    TextField("Email", text: $requesterEmail)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                }

                Section("Attachment") {
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        Label(imageData == nil ? "Attach Screenshot" : "Change Screenshot", systemImage: "photo")
                    }

                    #if canImport(UIKit)
                    if let data = imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 180)
                            .cornerRadius(12)
                            .padding(.vertical)
                    }
                    #elseif canImport(AppKit)
                    if let data = imageData, let nsImage = NSImage(data: data) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 180)
                            .cornerRadius(12)
                            .padding(.vertical)
                    }
                    #endif
                }
            }
            .navigationTitle("New Ticket")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit", action: submit)
                        .disabled(!isFormValid || isSaving)
                }
            }
            .task(id: selectedImage) {
                guard let data = try? await selectedImage?.loadTransferable(type: Data.self) else { return }
                imageData = data
            }
            .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var isFormValid: Bool {
        !title.isEmpty && !detail.isEmpty && requesterEmail.contains("@")
    }

    private func submit() {
        isSaving = true
        Task {
            let request = TicketCreationRequest(
                title: title,
                detail: detail,
                channel: channel,
                requesterEmail: requesterEmail,
                screenshotBase64: imageData?.base64EncodedString()
            )
            let error = await onCreate(request)
            await MainActor.run {
                isSaving = false
                if let error {
                    errorMessage = error
                } else {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    TicketComposerView(onCreate: { _ in nil })
}
