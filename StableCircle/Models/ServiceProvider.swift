import Foundation
import SwiftData

@Model
final class ServiceProvider: Identifiable, Codable {
    var id: UUID
    var name: String
    var serviceType: ServiceType
    var phone: String
    var mobile: String
    var email: String
    var address: String
    var city: String
    var state: String
    var zipCode: String
    var website: String
    var facebook: String
    var twitter: String
    var instagram: String
    var hoursOfOperation: String
    var isApproved: Bool
    var dateAdded: Date
    var dateApproved: Date?
    var reviewIds: [UUID] = []
    var addedByUserId: UUID?

    init(id: UUID = UUID(), name: String, serviceType: ServiceType, phone: String, mobile: String, email: String, address: String, city: String, state: String, zipCode: String, website: String = "", facebook: String = "", twitter: String = "", instagram: String = "", hoursOfOperation: String, addedByUserId: UUID?, isApproved: Bool = false) {
        self.id = id
        self.name = name
        self.serviceType = serviceType
        self.phone = phone
        self.mobile = mobile
        self.email = email
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.website = website
        self.facebook = facebook
        self.twitter = twitter
        self.instagram = instagram
        self.hoursOfOperation = hoursOfOperation
        self.addedByUserId = addedByUserId
        self.isApproved = isApproved
        self.dateAdded = Date()
    }

    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, name, serviceType, phone, mobile, email, address, city, state, zipCode, website, facebook, twitter, instagram, hoursOfOperation, isApproved, dateAdded, dateApproved, reviewIds, addedByUserId
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        serviceType = try container.decode(ServiceType.self, forKey: .serviceType)
        phone = try container.decode(String.self, forKey: .phone)
        mobile = try container.decode(String.self, forKey: .mobile)
        email = try container.decode(String.self, forKey: .email)
        address = try container.decode(String.self, forKey: .address)
        city = try container.decode(String.self, forKey: .city)
        state = try container.decode(String.self, forKey: .state)
        zipCode = try container.decode(String.self, forKey: .zipCode)
        website = try container.decode(String.self, forKey: .website)
        facebook = try container.decode(String.self, forKey: .facebook)
        twitter = try container.decode(String.self, forKey: .twitter)
        instagram = try container.decode(String.self, forKey: .instagram)
        hoursOfOperation = try container.decode(String.self, forKey: .hoursOfOperation)
        isApproved = try container.decode(Bool.self, forKey: .isApproved)
        dateAdded = try container.decode(Date.self, forKey: .dateAdded)
        dateApproved = try container.decodeIfPresent(Date.self, forKey: .dateApproved)
        reviewIds = try container.decode([UUID].self, forKey: .reviewIds)
        addedByUserId = try container.decodeIfPresent(UUID.self, forKey: .addedByUserId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(serviceType, forKey: .serviceType)
        try container.encode(phone, forKey: .phone)
        try container.encode(mobile, forKey: .mobile)
        try container.encode(email, forKey: .email)
        try container.encode(address, forKey: .address)
        try container.encode(city, forKey: .city)
        try container.encode(state, forKey: .state)
        try container.encode(zipCode, forKey: .zipCode)
        try container.encode(website, forKey: .website)
        try container.encode(facebook, forKey: .facebook)
        try container.encode(twitter, forKey: .twitter)
        try container.encode(instagram, forKey: .instagram)
        try container.encode(hoursOfOperation, forKey: .hoursOfOperation)
        try container.encode(isApproved, forKey: .isApproved)
        try container.encode(dateAdded, forKey: .dateAdded)
        try container.encodeIfPresent(dateApproved, forKey: .dateApproved)
        try container.encode(reviewIds, forKey: .reviewIds)
        try container.encodeIfPresent(addedByUserId, forKey: .addedByUserId)
    }
}

enum ServiceType: String, CaseIterable, Codable {
    case veterinarian = "Veterinarian"
    case trainer = "Trainer"
    case farrier = "Farrier"
    case blanketWasher = "Blanket Washer"
    case other = "Other"
}
