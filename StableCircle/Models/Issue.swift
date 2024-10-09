import SwiftUI
import SwiftData

@Model
final class Issue: Identifiable {
    var id: UUID
    var title: String
    var issueDescription: String  // Changed from 'description'
    var category: IssueCategory
    var images: [Data]?
    var reportedBy: User
    var reportedDate: Date
    var status: IssueStatus
    var isPublic: Bool
    var adminNotes: String?

    init(id: UUID = UUID(), title: String, issueDescription: String, category: IssueCategory, images: [Data]? = nil, reportedBy: User, reportedDate: Date = Date(), status: IssueStatus = .reported, isPublic: Bool = false, adminNotes: String? = nil) {
        self.id = id
        self.title = title
        self.issueDescription = issueDescription  // Changed from 'description'
        self.category = category
        self.images = images
        self.reportedBy = reportedBy
        self.reportedDate = reportedDate
        self.status = status
        self.isPublic = isPublic
        self.adminNotes = adminNotes
    }
}

enum IssueCategory: String, Codable, CaseIterable {
    case water = "Water"
    case feed = "Feed"
    case fencing = "Fencing"
    case facilityMaintenance = "Facility Maintenance"
}

enum IssueStatus: String, Codable, CaseIterable {
    case reported = "Reported"
    case underReview = "Under Review"
    case inProgress = "In Progress"
    case resolved = "Resolved"
    case closed = "Closed"
}
