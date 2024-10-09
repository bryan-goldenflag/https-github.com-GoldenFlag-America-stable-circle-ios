import Foundation
import SwiftData

@Model
final class User: Identifiable {
    var id: UUID
    var name: String
    var email: String
    var passwordHash: String
    var phoneNumber: String
    var emergencyContacts: String  // Changed from [String] to String
    var address: String
    var trackAndLot: String
    var role: UserRole
    var isApproved: Bool
    var isEmailVerified: Bool
    var emailVerificationToken: String?
    var passwordResetToken: String?
    var horses: [Horse]
    var reviewIds: [UUID] = []
  
    init(name: String, email: String, passwordHash: String, phoneNumber: String, emergencyContacts: String, address: String, trackAndLot: String) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.phoneNumber = phoneNumber
        self.emergencyContacts = emergencyContacts
        self.address = address
        self.trackAndLot = trackAndLot
        self.role = .member
        self.isApproved = false
        self.isEmailVerified = false
        self.emailVerificationToken = UUID().uuidString
        self.horses = []
    }
  
    var isAdmin: Bool {
        return role == .admin
    }
}

enum UserRole: String, Codable {
    case admin
    case member
    case publicUser
    case hoa
    case serviceProvider
}
