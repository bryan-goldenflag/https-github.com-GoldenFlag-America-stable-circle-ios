import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var isShowingSplash = true
    
    var body: some View {
        Group {
            if isShowingSplash {
                SplashScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isShowingSplash = false
                            }
                        }
                    }
            } else if authManager.isAuthenticated {
              MainMenuView()
                    .transition(.move(edge: .trailing))
            } else {
                LoginView()
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut, value: authManager.isAuthenticated)
        .animation(.easeInOut, value: isShowingSplash)
    }
}

struct SplashScreen: View {
    let primaryColor = Color(red: 0.2, green: 0.4, blue: 0.6)
    let secondaryColor = Color(red: 0.9, green: 0.95, blue: 1.0)
    
    var body: some View {
        ZStack {
            secondaryColor.edgesIgnoringSafeArea(.all)
            VStack {
                Image(systemName: "figure.equestrian.sports")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .foregroundColor(primaryColor)
                Text("StableCircle")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(primaryColor)
            }
        }
    }
}
