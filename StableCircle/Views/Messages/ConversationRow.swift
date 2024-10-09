import SwiftUI
import SwiftData

struct ConversationRow: View {
    let conversation: Conversation
    @Query private var users: [User]

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(getUserName(for: conversation.otherUserId))
                    .font(.headline)
                Text(conversation.latestMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            Spacer()
            Text(conversation.timestamp, style: .time)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    private func getUserName(for userId: UUID) -> String {
        users.first(where: { $0.id == userId })?.name ?? "Unknown User"
    }
}
