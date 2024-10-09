import Foundation
import SwiftData

@Model
final class Review: Identifiable {
    var id: UUID
    var rating: Int
    var comment: String
    var reviewerId: UUID?
    var serviceProviderId: UUID?
    var date: Date

    init(id: UUID = UUID(), rating: Int, comment: String, reviewerId: UUID?, serviceProviderId: UUID?, date: Date = Date()) {
        self.id = id
        self.rating = rating
        self.comment = comment
        self.reviewerId = reviewerId
        self.serviceProviderId = serviceProviderId
        self.date = date
    }

    func fetchServiceProvider(context: ModelContext) -> ServiceProvider? {
        guard let serviceProviderId = self.serviceProviderId else {
            return nil
        }
        let predicate = #Predicate<ServiceProvider> { $0.id == serviceProviderId }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try? context.fetch(descriptor).first
    }

    func fetchReviewer(context: ModelContext) -> User? {
        guard let reviewerId = self.reviewerId else {
            return nil
        }
        let predicate = #Predicate<User> { $0.id == reviewerId }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try? context.fetch(descriptor).first
    }
}
