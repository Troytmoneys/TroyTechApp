import SwiftUI

struct GoogleSignInButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "globe")
                Text("Sign in with Google")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .cornerRadius(8)
        }
    }
}

#Preview {
    GoogleSignInButton {}
        .padding()
}
