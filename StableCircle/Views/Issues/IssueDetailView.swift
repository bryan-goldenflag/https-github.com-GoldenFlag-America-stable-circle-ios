import SwiftUI
import SwiftData

struct IssueDetailView: View {
    @Bindable var issue: Issue
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(issue.title)
                    .font(.title)
                
                Text(issue.category.rawValue)
                    .font(.subheadline)
                
                Text(issue.issueDescription)
                    .font(.body)
                
                if showReportedBy {
                    Text("Reported by: \(issue.reportedBy.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("Status: \(issue.status.rawValue)")
                    .font(.headline)
                
                Text("Reported on: \(issue.reportedDate, style: .date)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let images = issue.images, !images.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(images, id: \.self) { imageData in
                                if let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                if authManager.currentUser?.isAdmin == true {
                    adminSection
                }
            }
            .padding()
        }
        .navigationTitle("Issue Details")
    }
    
    private var showReportedBy: Bool {
        authManager.currentUser?.role == .admin || authManager.currentUser?.role == .hoa
    }
    
    @ViewBuilder
    private var adminSection: some View {
        VStack(alignment: .leading) {
            Toggle("Public", isOn: $issue.isPublic)
            Picker("Status", selection: $issue.status) {
                ForEach(IssueStatus.allCases, id: \.self) { status in
                    Text(status.rawValue).tag(status)
                }
            }
            TextEditor(text: Binding(
                get: { issue.adminNotes ?? "" },
                set: { issue.adminNotes = $0 }
            ))
            .frame(height: 100)
            .border(Color.gray, width: 1)
        }
    }
}
