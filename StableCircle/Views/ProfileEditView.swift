import SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var phoneNumber: String
    @State private var address: String
    @State private var trackAndLot: String
    @State private var emergencyContacts: String
    
    init(user: User) {
        _name = State(initialValue: user.name)
        _phoneNumber = State(initialValue: user.phoneNumber)
        _address = State(initialValue: user.address)
        _trackAndLot = State(initialValue: user.trackAndLot)
        _emergencyContacts = State(initialValue: user.emergencyContacts)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                TextField("Name", text: $name)
                TextField("Phone Number", text: $phoneNumber)
            }
            
            Section(header: Text("Address")) {
                TextField("Address", text: $address)
                TextField("Track & Lot", text: $trackAndLot)
            }
            
            Section(header: Text("Emergency Contacts")) {
                TextField("Emergency Contacts (comma-separated)", text: $emergencyContacts)
            }
            
            Button("Save Changes") {
                authManager.updateUserProfile(
                    name: name,
                    phoneNumber: phoneNumber,
                    address: address,
                    trackAndLot: trackAndLot,
                    emergencyContacts: emergencyContacts
                )
                dismiss()
            }
        }
        .navigationTitle("Edit Profile")
    }
}
