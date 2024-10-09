import SwiftUI

struct MessageList: View {
    let messages: [Message]
    let currentUserId: UUID?

    var body: some View {
        List(messages) { message in
            MessageBubble(message: message, isCurrentUser: message.senderId == currentUserId)
        }
    }
}
