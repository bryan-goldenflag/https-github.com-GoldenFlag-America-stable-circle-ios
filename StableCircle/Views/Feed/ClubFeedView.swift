import SwiftUI
import SwiftData

struct ClubFeedView: View {
    @Query(filter: #Predicate<Message> { $0.isClubFeedPost == true },
           sort: \Message.timestamp, order: .reverse)
    private var feedMessages: [Message]

    var body: some View {
        List(feedMessages) { message in
            FeedMessageView(message: message)
        }
        .navigationTitle("Club Feed")
    }
}
