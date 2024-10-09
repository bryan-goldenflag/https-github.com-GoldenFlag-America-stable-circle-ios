import SwiftUI
import SwiftData

@main
struct StableCircleApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Horse.self,
            VeterinaryRecord.self,
            Post.self,
            Comment.self,
            Message.self,
            ServiceProvider.self,
            Review.self,
            Issue.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("Detailed error: \(error)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @StateObject private var authManager: AuthenticationManager
    @StateObject private var messageManager: MessageManager
    @StateObject private var webSocketManager: WebSocketManager
    
    init() {
        let context = sharedModelContainer.mainContext
        _authManager = StateObject(wrappedValue: AuthenticationManager(modelContext: context))
        _messageManager = StateObject(wrappedValue: MessageManager(modelContext: context))
      
//        DatabaseManager.cleanDatabase(sharedModelContainer)

        let userId: UUID
        if let uuidString = UserDefaults.standard.string(forKey: "userId"),
           let uuid = UUID(uuidString: uuidString) {
            userId = uuid
        } else {
            userId = UUID()
            UserDefaults.standard.set(userId.uuidString, forKey: "userId")
        }
        _webSocketManager = StateObject(wrappedValue: WebSocketManager(userId: userId))
    }
  
    var body: some Scene {
        WindowGroup {
            MainMenuView()
                .environmentObject(authManager)
                .environmentObject(messageManager)
                .environmentObject(webSocketManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
