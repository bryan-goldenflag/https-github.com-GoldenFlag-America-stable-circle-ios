import SwiftUI
import SwiftData

struct MessageListView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var messageManager: MessageManager
    @State private var showingNewMessageSheet = false
    @State private var conversations: [Conversation] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(conversations) { conversation in
                  NavigationLink(destination: ConversationView(otherUserId: conversation.otherUserId, currentUserId: authManager.currentUser?.id ?? UUID())) {
                      ConversationRow(conversation: conversation)
                  }
                }
            }
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewMessageSheet = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingNewMessageSheet) {
                NewMessageView()
            }
        }
        .onAppear(perform: loadConversations)
        .onChange(of: messageManager.shouldRefreshConversations) { _, newValue in
            if newValue {
                loadConversations()
                messageManager.shouldRefreshConversations = false
            }
        }
    }

    private func loadConversations() {
        guard let currentUserId = authManager.currentUser?.id else {
            print("No current user found")
            return
        }
        print("Loading conversations for user \(currentUserId)")
        let messages = messageManager.getConversations(for: currentUserId)
        
        print("Found \(messages.count) messages")

        let grouped = Dictionary(grouping: messages) { message in
            message.senderId == currentUserId ? message.recipientId : message.senderId
        }
        
        conversations = grouped.compactMap { (userId, messages) -> Conversation? in
            guard let otherUserId = userId,
                  let latestMessage = messages.max(by: { $0.timestamp < $1.timestamp }) else {
                return nil
            }
            
            return Conversation(
                id: UUID(),
                otherUserId: otherUserId,
                latestMessage: latestMessage.content,
                timestamp: latestMessage.timestamp
            )
        }.sorted { $0.timestamp > $1.timestamp }
        
        print("Created \(conversations.count) conversations")
    }
}
