import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var showingForgotPassword = false
    @State private var showingRegister = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    let primaryColor = Color(red: 0.2, green: 0.4, blue: 0.6) // Stable blue
    let secondaryColor = Color(red: 0.9, green: 0.95, blue: 1.0) // Light sky blue
    
    var body: some View {
        NavigationView {
            ZStack {
                secondaryColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Image(systemName: "figure.equestrian.sports")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(primaryColor)
                        .padding(.top, 50)
                    
                    Text("StableCircle")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(primaryColor)
                    
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedTextFieldStyle())
                    }
                    .padding(.horizontal, 30)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    Button(action: performLogin) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(primaryColor)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 30)
                    .disabled(isLoading)
                    
                    HStack {
                        Button("Forgot Password?") {
                            showingForgotPassword = true
                        }
                        .foregroundColor(primaryColor)
                        
                        Spacer()
                        
                        Button("Register") {
                            showingRegister = true
                        }
                        .foregroundColor(primaryColor)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingForgotPassword) {
                ForgotPasswordView()
            }
            .sheet(isPresented: $showingRegister) {
                RegisterView()
            }
            .overlay(
                LoadingView(isShowing: $isLoading)
            )
        }
    }
    
    private func performLogin() {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            authManager.login(email: email, password: password)
            isLoading = false
            
            if !authManager.isAuthenticated {
                errorMessage = "Invalid email or password. Please try again."
            }
        }
    }
}

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
            )
    }
}

struct LoadingView: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                    Text("Loading...")
                        .foregroundColor(.white)
                        .padding(.top, 20)
                }
            }
        }
    }
}
