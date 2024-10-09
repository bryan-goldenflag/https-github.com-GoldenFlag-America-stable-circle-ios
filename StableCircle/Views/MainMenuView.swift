import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var messageManager: MessageManager
    
    var body: some View {
        if let user = authManager.currentUser {
            switch user.role {
            case .admin:
                AdminTabView()
            case .member:
                MemberTabView()
            case .publicUser:
                PublicUserTabView()
            case .hoa:
                HOATabView()
            case .serviceProvider:
                ServiceProviderTabView()
            }
        } else {
            LoginView()
        }
    }
}

struct AdminTabView: View {
    var body: some View {
        TabView {
            HorseListView()
                .tabItem { Label("Horses", systemImage: "figure.equestrian.sports") }
            ClubFeedView()
                .tabItem { Label("Feed", systemImage: "list.bullet") }
            IssueListView()
                .tabItem { Label("Issues", systemImage: "exclamationmark.triangle") }
            MessageListView()
                .tabItem { Label("Messages", systemImage: "message") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
            ServiceProviderListView()
                .tabItem { Label("Services", systemImage: "person.3") }
            AdminView()
                .tabItem { Label("Admin", systemImage: "gear") }
        }
    }
}

struct MemberTabView: View {
    var body: some View {
        TabView {
            HorseListView()
                .tabItem { Label("Horses", systemImage: "horse") }
            ClubFeedView()
                .tabItem { Label("Feed", systemImage: "list.bullet") }
            IssueListView()
                .tabItem { Label("Issues", systemImage: "exclamationmark.triangle") }
            ServiceProviderListView()
                .tabItem { Label("Services", systemImage: "person.3") }
            MessageListView()
                .tabItem { Label("Messages", systemImage: "message") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}

struct PublicUserTabView: View {
    var body: some View {
        TabView {
            ClubFeedView()
                .tabItem { Label("Feed", systemImage: "list.bullet") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}

struct HOATabView: View {
    var body: some View {
        TabView {
            ClubFeedView()
                .tabItem { Label("Feed", systemImage: "list.bullet") }
            IssueListView()
                .tabItem { Label("Issues", systemImage: "exclamationmark.triangle") }
            MessageListView()
                .tabItem { Label("Messages", systemImage: "message") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}

struct ServiceProviderTabView: View {
    var body: some View {
        TabView {
            IssueListView()
                .tabItem { Label("Issues", systemImage: "exclamationmark.triangle") }
            MessageListView()
                .tabItem { Label("Messages", systemImage: "message") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
