import SwiftUI
import SwiftData

class AuthenticationManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        setupAdminAccountIfNeeded()
        setupTestAccounts()
    }
  
    func setupAdminAccountIfNeeded() {
        do {
            let descriptor = FetchDescriptor<User>()
            let allUsers = try modelContext.fetch(descriptor)
            let adminUsers = allUsers.filter { $0.role == .admin }
            
            if adminUsers.isEmpty {
                let adminUser = User(
                    name: "Admin",
                    email: "admin@stablecircle.com",
                    passwordHash: "admin",
                    phoneNumber: "1234567890",
                    emergencyContacts: "Emergency Contact",
                    address: "Admin Address",
                    trackAndLot: "Admin Track"
                )
                adminUser.role = .admin
                adminUser.isApproved = true
                adminUser.isEmailVerified = true
                
                modelContext.insert(adminUser)
                try modelContext.save()
                
                print("Admin account created successfully")
            } else {
                print("Admin account already exists")
            }
        } catch {
            print("Error setting up admin account: \(error)")
        }
    }
  
    func setupTestAccounts() {
        let testAccounts: [(String, String, UserRole)] = [
            ("Bryan", "bryan@stablecircle.com", .member),
            ("Vanessa", "vanessa@stablecircle.com", .member),
            ("Public User", "public@example.com", .publicUser),
            ("HOA User", "hoa@example.com", .hoa),
            ("Vet Provider", "vet@example.com", .serviceProvider)
        ]
        
        for (name, email, role) in testAccounts {
            let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.email == email })
            if (try? modelContext.fetch(descriptor))?.isEmpty ?? true {
                let user = User(
                    name: name,
                    email: email,
                    passwordHash: "password", // In a real app, use a secure hash
                    phoneNumber: "1234567890",
                    emergencyContacts: "Emergency Contact",
                    address: "123 Test St",
                    trackAndLot: "Track 1, Lot 1"
                )
                user.role = role
                user.isApproved = true
                user.isEmailVerified = true
                
                modelContext.insert(user)
                
                print("\(role) account created: \(email)")
            } else {
                print("\(role) account already exists: \(email)")
            }
        }
        
        try? modelContext.save()
    }
    
    func register(name: String, email: String, password: String, phoneNumber: String, emergencyContacts: String, address: String, trackAndLot: String) {
        let newUser = User(name: name, email: email, passwordHash: password, phoneNumber: phoneNumber, emergencyContacts: emergencyContacts, address: address, trackAndLot: trackAndLot)
        modelContext.insert(newUser)
        try? modelContext.save()
        sendVerificationEmail(to: newUser)
    }
    
    func verifyEmail(email: String, token: String) -> Bool {
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.email == email })
        if let user = try? modelContext.fetch(descriptor).first,
           user.emailVerificationToken == token {
            user.isEmailVerified = true
            user.emailVerificationToken = nil
            try? modelContext.save()
            return true
        }
        return false
    }
    
    func login(email: String, password: String) {
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.email == email })
        if let user = try? modelContext.fetch(descriptor).first,
           (user.passwordHash == password || user.isEmailVerified), // Allow login right after verification
           user.isEmailVerified {
            currentUser = user
            isAuthenticated = true
        }
    }
    
    private func sendVerificationEmail(to user: User) {
        // In a real app, you would send an actual email here
        print("Verification link: https://yourdomain.com/verify?token=\(user.emailVerificationToken ?? "")")
    }
  
    func requestPasswordReset(email: String) -> Bool {
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.email == email })
        if let user = try? modelContext.fetch(descriptor).first {
            user.passwordResetToken = UUID().uuidString
            try? modelContext.save()
            sendPasswordResetEmail(to: user)
            return true
        }
        return false
    }

    func resetPassword(token: String, newPassword: String) -> Bool {
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.passwordResetToken == token })
        if let user = try? modelContext.fetch(descriptor).first {
            user.passwordHash = newPassword // In a real app, hash this password
            user.passwordResetToken = nil
            try? modelContext.save()
            return true
        }
        return false
    }

    private func sendPasswordResetEmail(to user: User) {
        // In a real app, you would send an actual email here
        print("Password reset link: https://yourdomain.com/reset-password?token=\(user.passwordResetToken ?? "")")
    }
    
  
    func updateUserProfile(name: String, phoneNumber: String, address: String, trackAndLot: String, emergencyContacts: String) {
        if let user = currentUser {
            user.name = name
            user.phoneNumber = phoneNumber
            user.address = address
            user.trackAndLot = trackAndLot
            user.emergencyContacts = emergencyContacts
            
            try? modelContext.save()
            
            // Trigger a UI update
            objectWillChange.send()
        }
    }
  
    func checkAuthenticationState() {
        if let user = currentUser, user.isEmailVerified {
            isAuthenticated = true
        } else {
            isAuthenticated = false
            currentUser = nil
        }
    }
  
    func updateUser(_ updatedUser: User) {
        // In SwiftData, updates to managed objects are automatically tracked
        // We just need to save the context
        currentUser = updatedUser
        try? modelContext.save()
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
    }
}
