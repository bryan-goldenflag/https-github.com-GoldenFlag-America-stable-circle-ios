import Foundation

struct Conversation: Identifiable {
    let id: UUID
    let otherUserId: UUID
    let latestMessage: String
    let timestamp: Date
}
