import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @State private var verificationCode = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    let email: String
    
    var body: some View {
        VStack {
            Text("Enter the verification code sent to \(email)")
                .padding()
            
            TextField("Verification Code", text: $verificationCode)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Verify") {
                if authManager.verifyEmail(email: email, token: verificationCode) {
                    authManager.login(email: email, password: "") // We'll modify this in AuthenticationManager
                    dismiss()
                } else {
                    showAlert = true
                    alertMessage = "Invalid verification code. Please try again."
                }
            }
            .padding()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Verification Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}
