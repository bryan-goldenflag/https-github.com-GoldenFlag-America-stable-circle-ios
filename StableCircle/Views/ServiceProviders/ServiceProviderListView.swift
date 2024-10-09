import SwiftUI
import SwiftData

struct ServiceProviderListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var serviceProviders: [ServiceProvider]
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingAddProviderSheet = false
    @State private var searchText = ""
    @State private var selectedServiceType: ServiceType?

    var body: some View {
        NavigationView {
            VStack {
                Picker("Service Type", selection: $selectedServiceType) {
                    Text("All").tag(nil as ServiceType?)
                    ForEach(ServiceType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type as ServiceType?)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                List {
                    ForEach(filteredProviders) { provider in
                        NavigationLink(destination: ServiceProviderDetailView(provider: provider)) {
                            ServiceProviderRowView(provider: provider)
                        }
                    }
                }
            }
            .navigationTitle("Service Providers")
            .searchable(text: $searchText, prompt: "Search providers")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddProviderSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddProviderSheet) {
            AddServiceProviderView()
        }
    }

    private var filteredProviders: [ServiceProvider] {
        let visibleProviders = serviceProviders.filter { provider in
            provider.isApproved ||
            authManager.currentUser?.isAdmin == true ||
            provider.addedByUserId == authManager.currentUser?.id
        }
        
        let typeFilteredProviders = selectedServiceType == nil ? visibleProviders :
            visibleProviders.filter { $0.serviceType == selectedServiceType }
        
        if searchText.isEmpty {
            return typeFilteredProviders
        } else {
            return typeFilteredProviders.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.serviceType.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct ServiceProviderRowView: View {
    @Environment(\.modelContext) private var modelContext
    let provider: ServiceProvider

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(provider.name)
                .font(.headline)
            Text(provider.serviceType.rawValue)
                .font(.subheadline)
            HStack {
            }
            .font(.caption)
            if !provider.isApproved {
                Text("Pending Approval")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
}
