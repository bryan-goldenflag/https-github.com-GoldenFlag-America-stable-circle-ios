import SwiftUI
import SwiftData

struct AdminIssueManagementView: View {
    @Query private var issues: [Issue]
    @State private var selectedIssue: Issue?
    @State private var isReportGeneratorPresented = false
    
    var body: some View {
        List {
            ForEach(issues) { issue in
                IssueRowView(issue: issue)
                    .onTapGesture {
                        selectedIssue = issue
                    }
            }
        }
        .navigationTitle("Manage Issues")
        .sheet(item: $selectedIssue) { issue in
            IssueDetailView(issue: issue)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Generate Report") {
                    isReportGeneratorPresented = true
                }
            }
        }
        .sheet(isPresented: $isReportGeneratorPresented) {
            ReportGeneratorView(issues: issues)
        }
    }
}

struct ReportGeneratorView: View {
    let issues: [Issue]
    @State private var selectedCategories: Set<IssueCategory> = Set(IssueCategory.allCases)
    @State private var selectedStatuses: Set<IssueStatus> = Set(IssueStatus.allCases)
    @State private var startDate = Date().addingTimeInterval(-30*24*60*60) // 30 days ago
    @State private var endDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Categories")) {
                    ForEach(IssueCategory.allCases, id: \.self) { category in
                        Toggle(category.rawValue, isOn: Binding(
                            get: { selectedCategories.contains(category) },
                            set: { if $0 { selectedCategories.insert(category) } else { selectedCategories.remove(category) } }
                        ))
                    }
                }
                
                Section(header: Text("Statuses")) {
                    ForEach(IssueStatus.allCases, id: \.self) { status in
                        Toggle(status.rawValue, isOn: Binding(
                            get: { selectedStatuses.contains(status) },
                            set: { if $0 { selectedStatuses.insert(status) } else { selectedStatuses.remove(status) } }
                        ))
                    }
                }
                
                Section(header: Text("Date Range")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
                
                Button("Generate and Email Report") {
                    generateAndEmailReport()
                }
            }
            .navigationTitle("Generate Report")
        }
    }
    
    private func generateAndEmailReport() {
        let filteredIssues = issues.filter { issue in
            selectedCategories.contains(issue.category) &&
            selectedStatuses.contains(issue.status) &&
            issue.reportedDate >= startDate &&
            issue.reportedDate <= endDate
        }
        
        // Implement report generation and emailing functionality here
        // You might want to use a library like MessageUI for emailing
        print("Generating report for \(filteredIssues.count) issues")
    }
}
