import SwiftUI
import SwiftData

class WebSocketManager: ObservableObject {
    @Published var latestMessage: Message?
    private var webSocketTask: URLSessionWebSocketTask?
    private let userId: UUID
    @Environment(\.modelContext) private var modelContext
    
    init(userId: UUID) {
        self.userId = userId
    }
    
    func connect() {
        guard let url = URL(string: "ws://localhost:3000") else { return }
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        print("WebSocket connected")
        receiveMessage()
        
        sendMessage(["type": "register", "userId": userId.uuidString])
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        print("WebSocket disconnected")
    }
    
    func sendMessage(_ message: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: message),
              let string = String(data: data, encoding: .utf8) else {
            print("Failed to encode message")
            return
        }
        webSocketTask?.send(.string(string)) { error in
            if let error = error {
                print("Error sending message: \(error)")
            }
        }
    }
    
    func updateMessageStatus(messageId: UUID, status: MessageStatus) {
        let message = ["type": "updateStatus", "messageId": messageId.uuidString, "status": status.rawValue]
        sendMessage(message)
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("WebSocket receiving error: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received WebSocket message: \(text)")
                    if let data = text.data(using: .utf8) {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                if json["type"] as? String == "newMessage",
                                   let messageData = try? JSONSerialization.data(withJSONObject: json["message"] as Any),
                                   let decodedMessage = try? JSONDecoder().decode(Message.self, from: messageData) {
                                    DispatchQueue.main.async {
                                        self?.latestMessage = decodedMessage
                                        print("Decoded new message: \(decodedMessage)")
                                    }
                                } else if json["type"] as? String == "statusUpdate",
                                          let messageId = UUID(uuidString: json["messageId"] as? String ?? ""),
                                          let statusRawValue = json["status"] as? String,
                                          let status = MessageStatus(rawValue: statusRawValue) {
                                    self?.updateMessageStatusLocally(messageId: messageId, status: status)
                                }
                            }
                        } catch {
                            print("Error parsing WebSocket message: \(error)")
                        }
                    }
                case .data(let data):
                    print("Received binary data: \(data)")
                @unknown default:
                    break
                }
                self?.receiveMessage()
            }
        }
    }

    private func updateMessageStatusLocally(messageId: UUID, status: MessageStatus) {
        DispatchQueue.main.async {
            let fetchDescriptor = FetchDescriptor<Message>(predicate: #Predicate { $0.id == messageId })
            if let message = try? self.modelContext.fetch(fetchDescriptor).first {
                message.status = status
                try? self.modelContext.save()
                NotificationCenter.default.post(name: .messageStatusUpdated, object: nil, userInfo: ["messageId": messageId, "status": status])
            }
        }
    }
}
