import SwiftUI
import SwiftData

struct ReportIssueView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var title = ""
    @State private var issueDescription = ""
    @State private var category: IssueCategory = .water
    @State private var images: [UIImage] = []
    @State private var isImagePickerPresented = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Issue Details")) {
                    TextField("Title", text: $title)
                    Picker("Category", selection: $category) {
                        ForEach(IssueCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    TextEditor(text: $issueDescription)
                        .frame(height: 100)
                }
                
                Section(header: Text("Images")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(images, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                            }
                            Button(action: { isImagePickerPresented = true }) {
                                Image(systemName: "plus")
                                    .frame(width: 100, height: 100)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Button("Submit Report") {
                    submitReport()
                }
            }
            .navigationTitle("Report Issue")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        submitReport()
                    }
                }
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(images: $images)
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Report Issue"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func submitReport() {
        guard let currentUser = authManager.currentUser else {
            alertMessage = "Error: User not logged in"
            showingAlert = true
            return
        }
        
        guard !title.isEmpty && !issueDescription.isEmpty else {
            alertMessage = "Please fill in both title and description"
            showingAlert = true
            return
        }
        
        let imageData = images.compactMap { $0.jpegData(compressionQuality: 0.8) }
        let newIssue = Issue(title: title, issueDescription: issueDescription, category: category, images: imageData, reportedBy: currentUser)
        
        modelContext.insert(newIssue)
        
        do {
            try modelContext.save()
            alertMessage = "Issue reported successfully"
            showingAlert = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                dismiss()
            }
        } catch {
            alertMessage = "Error saving issue: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}
