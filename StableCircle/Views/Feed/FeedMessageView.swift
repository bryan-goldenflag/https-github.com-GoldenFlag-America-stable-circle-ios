import SwiftUI
import SwiftData

struct FeedMessageView: View {
    let message: Message
    @Query private var users: [User]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(getUserName(for: message.senderId))
                    .font(.headline)
                Spacer()
                Text(message.timestamp, style: .relative)
                    .font(.caption)
            }
            Text(message.content)
        }
        .padding(.vertical, 8)
    }

    private func getUserName(for userId: UUID) -> String {
        users.first(where: { $0.id == userId })?.name ?? "Unknown User"
    }
}
