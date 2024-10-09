import SwiftUI
import SwiftData

struct AddServiceProviderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager

    @State private var name = ""
    @State private var serviceType: ServiceType = .other
    @State private var phone = ""
    @State private var mobile = ""
    @State private var email = ""
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var website = ""
    @State private var facebook = ""
    @State private var twitter = ""
    @State private var instagram = ""
    @State private var hoursOfOperation = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $name)
                    Picker("Service Type", selection: $serviceType) {
                        ForEach(ServiceType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Contact Information")) {
                    TextField("Phone", text: $phone)
                    TextField("Mobile", text: $mobile)
                    TextField("Email", text: $email)
                }
                
                Section(header: Text("Address")) {
                    TextField("Address", text: $address)
                    TextField("City", text: $city)
                    TextField("State", text: $state)
                    TextField("Zip Code", text: $zipCode)
                }
                
                Section(header: Text("Social Media")) {
                    TextField("Website", text: $website)
                    TextField("Facebook", text: $facebook)
                    TextField("Twitter", text: $twitter)
                    TextField("Instagram", text: $instagram)
                }
                
                Section(header: Text("Hours of Operation")) {
                    TextEditor(text: $hoursOfOperation)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Service Provider")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addServiceProvider() }
                }
            }
        }
    }

  private func addServiceProvider() {
      guard let currentUser = authManager.currentUser else { return }
      let newProvider = ServiceProvider(
          name: name,
          serviceType: serviceType,
          phone: phone,
          mobile: mobile,
          email: email,
          address: address,
          city: city,
          state: state,
          zipCode: zipCode,
          website: website,
          facebook: facebook,
          twitter: twitter,
          instagram: instagram,
          hoursOfOperation: hoursOfOperation,
          addedByUserId: currentUser.id
      )
      
      // First, insert into local database
      modelContext.insert(newProvider)
      try? modelContext.save()
      
      // Then, send to backend
      Task {
          do {
              let savedProvider = try await APIClient.shared.sendObject(newProvider, endpoint: "serviceprovider")
              print("Provider successfully sent to backend: \(savedProvider)")
              
              // Optionally update the local object with any changes from the server
              // TBC
              if let updatedProvider = try? modelContext.fetch(FetchDescriptor<ServiceProvider>(predicate: #Predicate { $0.id == savedProvider.id })).first {
                  //updatedProvider.update(from: savedProvider)
                  try? modelContext.save()
              }
              
              await MainActor.run {
                  dismiss()
              }
          } catch {
              print("Error sending provider to backend: \(error)")
              // Handle error (e.g., show an alert to the user)
              await MainActor.run {
                  // Show error alert
              }
          }
      }
  }
  
}
