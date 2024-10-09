import Foundation
import SwiftData

@Model
final class Post {
    var id: UUID
    var content: String
    var category: PostCategory
    var author: User?
    var createdAt: Date
    var likes: [User]
    var comments: [Comment]
    
    init(content: String, category: PostCategory) {
        self.id = UUID()
        self.content = content
        self.category = category
        self.createdAt = Date()
        self.likes = []
        self.comments = []
    }
}

enum PostCategory: String, Codable, CaseIterable {
    case announcement
    case event
    case buySell
    case discussion
}

@Model
final class Comment {
    var id: UUID
    var content: String
    var author: User?
    var createdAt: Date
    
    init(content: String) {
        self.id = UUID()
        self.content = content
        self.createdAt = Date()
    }
}
