import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var phoneNumber = ""
    @State private var emergencyContact = ""
    @State private var address = ""
    @State private var trackAndLot = ""
    @State private var showingVerification = false
    
    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                SecureField("Password", text: $password)
                TextField("Phone Number", text: $phoneNumber)
                    .keyboardType(.phonePad)
            }
            
            Section(header: Text("Emergency Contact")) {
                TextField("Emergency Contact", text: $emergencyContact)
            }
            
            Section(header: Text("Address")) {
                TextField("Address", text: $address)
                TextField("Track & Lot", text: $trackAndLot)
            }
            
            Button("Register") {
                authManager.register(name: name,
                                     email: email,
                                     password: password,
                                     phoneNumber: phoneNumber,
                                     emergencyContacts: emergencyContact,
                                     address: address,
                                     trackAndLot: trackAndLot)
                showingVerification = true
            }
        }
        .navigationTitle("Register")
        .sheet(isPresented: $showingVerification) {
            EmailVerificationView(email: email)
        }
    }
}
