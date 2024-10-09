import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    Text("Name: \(authManager.currentUser?.name ?? "")")
                    Text("Email: \(authManager.currentUser?.email ?? "")")
                    Text("Phone: \(authManager.currentUser?.phoneNumber ?? "")")
                }
                
                Section(header: Text("Address")) {
                    Text("Address: \(authManager.currentUser?.address ?? "")")
                    Text("Track & Lot: \(authManager.currentUser?.trackAndLot ?? "")")
                }
                
                Section(header: Text("Emergency Contacts")) {
                    Text(authManager.currentUser?.emergencyContacts ?? "")
                }
                
                Button("Logout") {
                    authManager.logout()
                }
                .foregroundColor(.red)
            }
            .navigationTitle("Profile")
            .toolbar {
                Button("Edit") {
                    showingEditProfile = true
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                if let user = authManager.currentUser {
                    ProfileEditView(user: user)
                }
            }
        }
    }
}
