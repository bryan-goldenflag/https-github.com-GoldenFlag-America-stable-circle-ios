import SwiftUI
import SwiftData

struct ServiceProviderDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @Bindable var provider: ServiceProvider
    @State private var showingConfirmationDialog = false
    @State private var isEditing = false
    
    private var canEdit: Bool {
        authManager.currentUser?.isAdmin == true ||
        authManager.currentUser?.id == provider.id ||
        (!provider.isApproved && authManager.currentUser?.id == provider.id)
    }

    var body: some View {
        Form {
            Section(header: Text("BASIC INFORMATION")) {
                editableField("Name", text: $provider.name)
                if isEditing {
                    Picker("Service Type", selection: $provider.serviceType) {
                        ForEach(ServiceType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                } else {
                    LabeledContent("Service Type", value: provider.serviceType.rawValue)
                }
            }
            
            Section(header: Text("CONTACT INFORMATION")) {
                editableField("Phone", text: $provider.phone)
                editableField("Mobile", text: $provider.mobile)
                editableField("Email", text: $provider.email)
                editableField("Address", text: $provider.address)
                editableField("City", text: $provider.city)
                editableField("State", text: $provider.state)
                editableField("Zip Code", text: $provider.zipCode)
            }
            
            Section(header: Text("SOCIAL MEDIA")) {
                editableField("Website", text: $provider.website)
                editableField("Facebook", text: $provider.facebook)
                editableField("Twitter", text: $provider.twitter)
                editableField("Instagram", text: $provider.instagram)
            }
            
            Section(header: Text("HOURS OF OPERATION")) {
                if isEditing {
                    TextEditor(text: $provider.hoursOfOperation)
                        .frame(height: 100)
                } else {
                    Text(provider.hoursOfOperation)
                }
            }
            
            if authManager.currentUser?.isAdmin == true {
                Section(header: Text("ADMIN ACTIONS")) {
                    adminActions
                }
            }
        }
        .navigationTitle("Provider Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if canEdit {
                    Button(isEditing ? "Done" : "Edit") {
                        if isEditing {
                            try? modelContext.save()
                        }
                        isEditing.toggle()
                    }
                }
            }
        }
        .environment(\.editMode, .constant(isEditing ? .active : .inactive))
        .confirmationDialog("Are you sure?", isPresented: $showingConfirmationDialog, titleVisibility: .visible) {
            Button("Revoke Approval", role: .destructive) {
                provider.isApproved = false
                provider.dateApproved = nil
                try? modelContext.save()
            }
        }
    }
    
    private var adminActions: some View {
        Group {
            if provider.isApproved {
                Button("Revoke Approval") {
                    showingConfirmationDialog = true
                }
                .foregroundColor(.red)
            } else {
                Button("Approve Provider") {
                    provider.isApproved = true
                    provider.dateApproved = Date()
                    try? modelContext.save()
                }
            }
            Text("Added on: \(provider.dateAdded, style: .date)")
            if let dateApproved = provider.dateApproved {
                Text("Approved on: \(dateApproved, style: .date)")
            }
        }
    }
    
    private func editableField(_ label: String, text: Binding<String>) -> some View {
        Group {
            if isEditing {
                TextField(label, text: text)
            } else {
                LabeledContent(label, value: text.wrappedValue)
            }
        }
    }
}
