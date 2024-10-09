import SwiftUI
import SwiftData

class DatabaseManager {
    static func cleanDatabase(_ modelContainer: ModelContainer) {
        let context = ModelContext(modelContainer)
        
        // List all your model types here
        let models: [any PersistentModel.Type] = [
            ServiceProvider.self,
            Review.self,
            Issue.self,
            User.self
            // Add any other model types you have
        ]
        
        for model in models {
            do {
                try context.delete(model: model)
                print("Deleted all instances of \(model)")
            } catch {
                print("Failed to delete \(model): \(error)")
            }
        }
        
        // Save changes
        do {
            try context.save()
            print("Database cleaned successfully")
        } catch {
            print("Failed to save changes after cleaning: \(error)")
        }
    }
}
