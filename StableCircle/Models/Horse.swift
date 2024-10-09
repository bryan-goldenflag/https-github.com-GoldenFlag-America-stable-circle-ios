import Foundation

import SwiftUI
import SwiftData

@Model
final class Horse {
    var id: UUID
    var name: String
    var breed: String
    var dateOfBirth: Date
    var color: String
    var medicalConditions: String
    var dietaryRestrictions: String
    var feedingSchedule: String
    var publicInfo: String
    var owner: User?
    var veterinaryRecords: [VeterinaryRecord]
    var careSchedules: [CareSchedule]
    var photos: [Photo] = []

    init(name: String, breed: String, dateOfBirth: Date, color: String) {
        self.id = UUID()
        self.name = name
        self.breed = breed
        self.dateOfBirth = dateOfBirth
        self.color = color
        self.medicalConditions = ""
        self.dietaryRestrictions = ""
        self.feedingSchedule = ""
        self.publicInfo = ""
        self.veterinaryRecords = []
        self.careSchedules = []
        self.photos = []
    }
}

@Model
final class VeterinaryRecord {
    var id: UUID
    var date: Date
    var procedure: String  // Changed from 'description' to 'procedure'
    var veterinarian: String
    var horse: Horse?

    init(date: Date, procedure: String, veterinarian: String) {
        self.id = UUID()
        self.date = date
        self.procedure = procedure
        self.veterinarian = veterinarian
    }
}

@Model
final class CareSchedule {
    var id: UUID
    var type: String // e.g., "Feeding", "Grooming", "Exercise"
    var frequency: String
    var notes: String
    var horse: Horse?

    init(type: String, frequency: String, notes: String) {
        self.id = UUID()
        self.type = type
        self.frequency = frequency
        self.notes = notes
    }
}

@Model
final class Photo {
    var id: UUID
    var imageData: Data
    var caption: String
    var dateTaken: Date
    var isProfilePicture: Bool
    
    init(imageData: Data, caption: String = "", isProfilePicture: Bool = false) {
        self.id = UUID()
        self.imageData = imageData
        self.caption = caption
        self.dateTaken = Date()
        self.isProfilePicture = isProfilePicture
    }
}
