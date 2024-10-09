import SwiftUI
import SwiftData

struct AdminView: View {
    @Query private var unapprovedUsers: [User]
    @Environment(\.modelContext) private var modelContext
    
    init() {
        _unapprovedUsers = Query(filter: #Predicate<User> { !$0.isApproved })
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(unapprovedUsers) { user in
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .font(.headline)
                        Text(user.email)
                            .font(.subheadline)
                    }
                    .swipeActions {
                        Button("Approve") {
                            approveUser(user)
                        }
                        .tint(.green)
                        
                        Button("Reject") {
                            rejectUser(user)
                        }
                        .tint(.red)
                    }
                }
            }
            .navigationTitle("User Approval")
        }
    }
    
    private func approveUser(_ user: User) {
        user.isApproved = true
        try? modelContext.save()
    }
    
    private func rejectUser(_ user: User) {
        modelContext.delete(user)
        try? modelContext.save()
    }
}
