import SwiftUI
import SwiftData

struct AddReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    let provider: ServiceProvider
    
    @State private var rating: Int = 3
    @State private var comment: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rating")) {
                    Picker("Rating", selection: $rating) {
                        ForEach(1...5, id: \.self) { number in
                            Text("\(number) stars")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Comment")) {
                    TextEditor(text: $comment)
                        .frame(height: 200)
                }
                
                Button("Submit Review") {
                    submitReview()
                }
            }
            .navigationTitle("Add Review")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private func submitReview() {
        guard let currentUser = authManager.currentUser else {
            // Handle the case where there's no current user
            return
        }
        
        let newReview = Review(
            rating: rating,
            comment: comment,
            reviewerId: currentUser.id,
            serviceProviderId: provider.id
        )
        
        modelContext.insert(newReview)
        provider.reviewIds.append(newReview.id)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            // Handle the error (e.g., show an alert)
            print("Error saving review: \(error)")
        }
    }
}
