import Foundation
import SwiftData

@Model
final class Message: Codable {
    var id: UUID
    var senderId: UUID
    var recipientId: UUID?
    var content: String
    var isClubFeedPost: Bool
    var timestamp: Date
    var status: MessageStatus

    enum CodingKeys: String, CodingKey {
        case id, senderId, recipientId, content, isClubFeedPost, timestamp, status
    }

    init(id: UUID = UUID(), senderId: UUID, recipientId: UUID?, content: String, isClubFeedPost: Bool, timestamp: Date = Date(), status: MessageStatus = .sent) {
        self.id = id
        self.senderId = senderId
        self.recipientId = recipientId
        self.content = content
        self.isClubFeedPost = isClubFeedPost
        self.timestamp = timestamp
        self.status = status
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        senderId = try container.decode(UUID.self, forKey: .senderId)
        recipientId = try container.decodeIfPresent(UUID.self, forKey: .recipientId)
        content = try container.decode(String.self, forKey: .content)
        isClubFeedPost = try container.decode(Bool.self, forKey: .isClubFeedPost)
        let timestampDouble = try container.decode(Double.self, forKey: .timestamp)
        timestamp = Date(timeIntervalSince1970: timestampDouble / 1000.0)
        status = try container.decode(MessageStatus.self, forKey: .status)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(senderId, forKey: .senderId)
        try container.encodeIfPresent(recipientId, forKey: .recipientId)
        try container.encode(content, forKey: .content)
        try container.encode(isClubFeedPost, forKey: .isClubFeedPost)
        try container.encode(timestamp.timeIntervalSince1970 * 1000, forKey: .timestamp)
        try container.encode(status, forKey: .status)
    }
}

enum MessageStatus: String, Codable {
    case sent
    case delivered
    case read
}
