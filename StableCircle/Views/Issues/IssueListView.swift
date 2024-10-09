import SwiftUI
import SwiftData

struct IssueListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @Query private var allIssues: [Issue]
    
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .dateDescending
    @State private var statusFilter: IssueStatus?
    @State private var showingReportIssueView = false

    var body: some View {
        NavigationView {
            VStack {
                filterAndSortBar
                
                List {
                    ForEach(filteredAndSortedIssues) { issue in
                        NavigationLink(destination: IssueDetailView(issue: issue)) {
                            IssueRowView(issue: issue)
                        }
                    }
                    .onDelete(perform: deleteIssues)
                }
            }
            .navigationTitle("Reported Issues")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingReportIssueView = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search issues")
        }
        .sheet(isPresented: $showingReportIssueView) {
            ReportIssueView()
        }
    }

    private var filterAndSortBar: some View {
        HStack {
            Menu {
                Picker("Sort", selection: $sortOrder) {
                    Text("Date (Newest First)").tag(SortOrder.dateDescending)
                    Text("Date (Oldest First)").tag(SortOrder.dateAscending)
                    Text("Status").tag(SortOrder.status)
                    Text("Category").tag(SortOrder.category)
                }
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }

            Menu {
                Button("All", action: { statusFilter = nil })
                ForEach(IssueStatus.allCases, id: \.self) { status in
                    Button(status.rawValue) {
                        statusFilter = status
                    }
                }
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
            }
        }
        .padding(.horizontal)
    }

    private var filteredAndSortedIssues: [Issue] {
        var issues = allIssues

        // Filter by user role
        if let currentUser = authManager.currentUser, currentUser.role != .admin && currentUser.role != .hoa {
            issues = issues.filter { $0.reportedBy.id == currentUser.id }
        }

        // Apply status filter
        if let statusFilter = statusFilter {
            issues = issues.filter { $0.status == statusFilter }
        }

        // Apply search
        if !searchText.isEmpty {
            issues = issues.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.issueDescription.localizedCaseInsensitiveContains(searchText) }
        }

        // Apply sorting
        switch sortOrder {
        case .dateDescending:
            issues.sort { $0.reportedDate > $1.reportedDate }
        case .dateAscending:
            issues.sort { $0.reportedDate < $1.reportedDate }
        case .status:
            issues.sort { $0.status.rawValue < $1.status.rawValue }
        case .category:
            issues.sort { $0.category.rawValue < $1.category.rawValue }
        }

        return issues
    }

    private func deleteIssues(at offsets: IndexSet) {
        for index in offsets {
            let issue = filteredAndSortedIssues[index]
            if issue.status != .resolved && issue.status != .closed {
                modelContext.delete(issue)
            }
        }
        try? modelContext.save()
    }
}

enum SortOrder {
    case dateDescending, dateAscending, status, category
}

struct IssueRowView: View {
    let issue: Issue
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(issue.title)
                    .font(.headline)
                Spacer()
                StatusBadge(status: issue.status)
            }
            
            HStack {
                Label(issue.category.rawValue, systemImage: "tag")
                Spacer()
                Text(issue.reportedDate, style: .date)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            if !issue.issueDescription.isEmpty {
                Text(issue.issueDescription)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
            }
            
            if showReportedBy {
                Text("Reported by: \(issue.reportedBy.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var showReportedBy: Bool {
        authManager.currentUser?.role == .admin || authManager.currentUser?.role == .hoa
    }
}

struct StatusBadge: View {
    let status: IssueStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
    
    var backgroundColor: Color {
        switch status {
        case .reported: return .orange
        case .underReview: return .blue
        case .inProgress: return .yellow
        case .resolved: return .green
        case .closed: return .gray
        }
    }
}
