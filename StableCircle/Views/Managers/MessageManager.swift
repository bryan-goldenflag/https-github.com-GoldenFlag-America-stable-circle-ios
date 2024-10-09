import SwiftUI
import SwiftData

@MainActor
class MessageManager: ObservableObject {
    @Published var shouldRefreshConversations = false
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

  func sendMessage(senderId: UUID, recipientId: UUID?, content: String, isClubFeedPost: Bool) async {
       let newMessage = Message(
           senderId: senderId,
           recipientId: recipientId,
           content: content,
           isClubFeedPost: isClubFeedPost,
           timestamp: Date(),
           status: .sent
       )
       
       do {
           // Save locally first
           modelContext.insert(newMessage)
           try modelContext.save()
           print("Message saved locally: \(newMessage)")
           
           // Send to backend
           let updatedMessage = try await APIClient.shared.sendObject(newMessage, endpoint: "message")
           // Update local message with server response
           newMessage.id = updatedMessage.id
           newMessage.status = updatedMessage.status
           try modelContext.save()
           
           print("Message sent to backend and updated locally: \(updatedMessage)")
//           self.shouldRefreshConversations = true
       } catch {
           print("Failed to send message: \(error)")
       }
   }

   func updateMessageStatus(_ message: Message, status: MessageStatus) async {
       do {
           try await APIClient.shared.updateMessageStatus(message.id, status: status)
           message.status = status
           try modelContext.save()
           print("Message status updated: \(status)")
//           self.shouldRefreshConversations = true
       } catch {
           print("Failed to update message status: \(error)")
       }
   }
  
    func getConversations(for userId: UUID) -> [Message] {
        let descriptor = FetchDescriptor<Message>(
            predicate: #Predicate {
                ($0.senderId == userId || $0.recipientId == userId) && !$0.isClubFeedPost
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        do {
            let messages = try modelContext.fetch(descriptor)
            print("Fetched \(messages.count) messages for user \(userId)")
            return messages
        } catch {
            print("Failed to fetch messages: \(error)")
            return []
        }
    }

    func triggerConversationRefresh() {
        shouldRefreshConversations = true
    }
}
