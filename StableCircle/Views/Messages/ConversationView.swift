import SwiftUI
import SwiftData

struct ConversationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var messageManager: MessageManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var newMessageText = ""
    @State private var scrollProxy: ScrollViewProxy?
    @State private var shouldDismiss = false
    @State private var isTyping = false
    @StateObject private var webSocketManager: WebSocketManager
    @State private var showNewMessagesBanner = false
    @State private var newMessagesCount = 0
    @State private var refreshTrigger = false
    let otherUserId: UUID
    
    @Query private var messages: [Message]
    
    init(otherUserId: UUID, currentUserId: UUID) {
        self.otherUserId = otherUserId
        self._webSocketManager = StateObject(wrappedValue: WebSocketManager(userId: currentUserId))
        self._messages = Query(filter: #Predicate<Message> { message in
            (message.senderId == otherUserId || message.recipientId == otherUserId) && !message.isClubFeedPost
        }, sort: [SortDescriptor(\Message.timestamp, order: .forward)])
    }

    var body: some View {
        VStack(spacing: 0) {
            if showNewMessagesBanner {
                newMessagesBanner
            }
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(messages) { message in
                            MessageBubble(message: message, isCurrentUser: message.senderId == authManager.currentUser?.id)
                                .id(message.id)
                        }
                    }
                }
                .onChange(of: messages.count) { _, _ in
                    scrollToBottom()
                }
                .onChange(of: messages.map { $0.status }) { _, _ in
                    scrollToBottom()
                }
                .onAppear {
                    scrollProxy = proxy
                    scrollToBottom()
                }
            }
            
            if isTyping {
                HStack {
                    Text("Typing...")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
            
            HStack {
                TextField("Type a message", text: $newMessageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
                .disabled(newMessageText.isEmpty)
                .padding(.trailing)
            }
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onAppear {
            print("ConversationView appeared for otherUserId: \(otherUserId)")
            webSocketManager.connect()
            setupNotifications()
            markMessagesAsRead()
        }
        .onDisappear {
            webSocketManager.disconnect()
            removeNotifications()
        }
        .onChange(of: shouldDismiss) { _, newValue in
            if newValue {
                dismiss()
            }
        }
        .onChange(of: webSocketManager.latestMessage) { _, newMessage in
            if let newMessage = newMessage {
                handleNewMessage(newMessage)
            }
        }
        .onChange(of: refreshTrigger) { _, _ in
            // This will cause the @Query to re-evaluate
        }
    }

    private var newMessagesBanner: some View {
        HStack {
            Text("\(newMessagesCount) new message\(newMessagesCount > 1 ? "s" : "")")
                .font(.caption)
                .padding(8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
        .transition(.move(edge: .top))
        .onTapGesture {
            scrollToBottom()
            showNewMessagesBanner = false
            newMessagesCount = 0
        }
    }

    private var backButton: some View {
        Button(action: {
            messageManager.triggerConversationRefresh()
            shouldDismiss = true
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        }
    }

    private func sendMessage() {
        guard let currentUser = authManager.currentUser else {
            print("No current user found")
            return
        }
        
        Task {
            await messageManager.sendMessage(
                senderId: currentUser.id,
                recipientId: otherUserId,
                content: newMessageText,
                isClubFeedPost: false
            )
            
            newMessageText = ""
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                scrollToBottom()
            }
        }
        
        print("Message sending initiated to user \(otherUserId)")
    }

    private func handleNewMessage(_ message: Message) {
        print("Handling new message: \(message)")
        if message.senderId == otherUserId || message.recipientId == otherUserId {
            if !messages.contains(where: { $0.id == message.id }) {
                modelContext.insert(message)
                print("Inserted new message into context")
                
                if message.senderId == otherUserId {
                    newMessagesCount += 1
                    showNewMessagesBanner = true
                    webSocketManager.updateMessageStatus(messageId: message.id, status: .delivered)
                }
            } else {
                if let existingMessage = messages.first(where: { $0.id == message.id }) {
                    existingMessage.status = message.status
                    print("Updated existing message status: \(message.id) to \(message.status)")
                }
            }
            
            do {
                try modelContext.save()
                print("Saved model context after handling new message")
                scrollToBottom()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }

    private func scrollToBottom() {
        withAnimation {
            scrollProxy?.scrollTo(messages.last?.id, anchor: .bottom)
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(forName: .newMessagesReceived, object: nil, queue: .main) { notification in
            if let count = notification.userInfo?["count"] as? Int {
                self.newMessagesCount += count
                self.showNewMessagesBanner = true
            }
        }
        
        NotificationCenter.default.addObserver(forName: .messagesUpdated, object: nil, queue: .main) { _ in
            self.refreshTrigger.toggle()
        }
        
        NotificationCenter.default.addObserver(forName: .messageStatusUpdated, object: nil, queue: .main) { notification in
            if let messageId = notification.userInfo?["messageId"] as? UUID,
               let status = notification.userInfo?["status"] as? MessageStatus {
                self.updateMessageStatus(messageId: messageId, status: status)
            }
        }
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: .newMessagesReceived, object: nil)
        NotificationCenter.default.removeObserver(self, name: .messagesUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: .messageStatusUpdated, object: nil)
    }
    
    private func updateMessageStatus(messageId: UUID, status: MessageStatus) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages[index].status = status
        }
    }
    
    private func markMessagesAsRead() {
        for message in messages where message.senderId == otherUserId && message.status != .read {
            message.status = .read
            webSocketManager.updateMessageStatus(messageId: message.id, status: .read)
        }
        try? modelContext.save()
    }
}

// Add this if not already present
extension Notification.Name {
    static let messageStatusUpdated = Notification.Name("messageStatusUpdated")
}
