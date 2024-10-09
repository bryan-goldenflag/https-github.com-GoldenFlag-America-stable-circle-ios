import SwiftUI

struct RegistrationView: View {
    @State private var currentStep = 1
    @State private var userData = UserData()
    
    var body: some View {
        VStack {
            switch currentStep {
            case 1:
                UserDetailsView(userData: $userData, nextStep: { currentStep = 2 })
            case 2:
                EmailConfirmationView(userData: userData, nextStep: { currentStep = 3 })
            case 3:
                AdminApprovalView(userData: userData)
            default:
                Text("Registration Complete")
            }
        }
    }
}

struct UserData {
    var name = ""
    var email = ""
    var phoneNumber = ""
    var emergencyContacts = [""]
    var address = ""
    var trackAndLot = ""
}

struct UserDetailsView: View {
    @Binding var userData: UserData
    var nextStep: () -> Void
    
    var body: some View {
        Form {
            TextField("Name", text: $userData.name)
            TextField("Email", text: $userData.email)
            TextField("Phone Number", text: $userData.phoneNumber)
            TextField("Address", text: $userData.address)
            TextField("Track & Lot", text: $userData.trackAndLot)
            // Add fields for emergency contacts
            
            Button("Next") {
                nextStep()
            }
        }
    }
}

struct EmailConfirmationView: View {
    let userData: UserData
    var nextStep: () -> Void
    
    var body: some View {
        VStack {
            Text("Please check your email for a confirmation link")
            Button("I've confirmed my email") {
                // Here you would typically verify with your backend
                nextStep()
            }
        }
    }
}

struct AdminApprovalView: View {
    let userData: UserData
    
    var body: some View {
        Text("Your registration is pending admin approval")
    }
}
