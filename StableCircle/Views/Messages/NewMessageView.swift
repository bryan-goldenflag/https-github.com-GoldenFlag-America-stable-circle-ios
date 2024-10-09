import SwiftUI
import SwiftData

struct NewMessageView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var messageManager: MessageManager
    @Environment(\.dismiss) private var dismiss
    @State private var messageContent = ""
    @State private var isClubFeedPost = false
    @State private var selectedRecipient: User?
    @Query private var users: [User]

    var body: some View {
        NavigationView {
            Form {
                Toggle("Post to Club Feed", isOn: $isClubFeedPost)

                if !isClubFeedPost {
                    Picker("Recipient", selection: $selectedRecipient) {
                        Text("Select a recipient").tag(nil as User?)
                        ForEach(users.filter { $0.id != authManager.currentUser?.id }) { user in
                            Text(user.name).tag(user as User?)
                        }
                    }
                }

                TextEditor(text: $messageContent)
                    .frame(height: 150)

                Button("Send") {
                    Task {
                        await sendMessage()
                    }
                }
                .disabled(messageContent.isEmpty || (!isClubFeedPost && selectedRecipient == nil))

            }
            .navigationTitle("New Message")
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
        }
    }

  private func sendMessage() async {
      guard let currentUser = authManager.currentUser else { return }
      
      await messageManager.sendMessage(
          senderId: currentUser.id,
          recipientId: isClubFeedPost ? nil : selectedRecipient?.id,
          content: messageContent,
          isClubFeedPost: isClubFeedPost
      )
      
      await MainActor.run {
          dismiss()
      }
  }
  
}
