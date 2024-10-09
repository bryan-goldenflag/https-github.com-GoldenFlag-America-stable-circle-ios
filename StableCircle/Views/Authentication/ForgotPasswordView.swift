import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var message = ""

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            Button("Request Password Reset") {
                if authManager.requestPasswordReset(email: email) {
                    message = "Check your email for password reset instructions."
                } else {
                    message = "No account found with that email address."
                }
            }
            .padding()
            
            Text(message)
                .foregroundColor(.blue)
                .padding()
        }
        .padding()
        .navigationTitle("Forgot Password")
    }
}
