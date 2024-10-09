import SwiftUI

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading) {
            HStack {
                if isCurrentUser {
                    Spacer()
                }
                Text(message.content)
                    .padding(10)
                    .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .cornerRadius(16)
                if !isCurrentUser {
                    Spacer()
                }
            }
            HStack {
                if isCurrentUser {
                    Spacer()
                    statusIndicator
                }
                Text(formatDate(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
                if !isCurrentUser {
                    Spacer()
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
    
    private var statusIndicator: some View {
        Group {
            switch message.status {
            case .sent:
                Image(systemName: "checkmark")
                    .foregroundColor(.gray)
            case .delivered:
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.blue)
            case .read:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .font(.caption2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
