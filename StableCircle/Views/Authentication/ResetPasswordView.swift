import SwiftUI

struct ResetPasswordView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var token = ""
    @State private var newPassword = ""
    @State private var message = ""

    var body: some View {
        VStack {
            TextField("Reset Token", text: $token)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("New Password", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Reset Password") {
                if authManager.resetPassword(token: token, newPassword: newPassword) {
                    message = "Password reset successfully. You can now log in with your new password."
                } else {
                    message = "Invalid or expired reset token. Please try again."
                }
            }
            .padding()
            
            Text(message)
                .foregroundColor(.blue)
                .padding()
        }
        .padding()
        .navigationTitle("Reset Password")
    }
}
