//
//  authHandler.swift
//  activityapp
//
//  Created by Ty Dickson on 5/6/26.
//
import SwiftUI
internal import Combine
internal import Auth
import Supabase
internal import System

@MainActor
class AuthHandler: ObservableObject {
    
    @Published var user : AppUser?
    @Published var session: Session?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    weak var appDelegate: AppDelegate? {
        didSet {
            if isAuthenticated, let userId = user?.id {
                appDelegate?.uploadToken(userId: userId)
            }
        }
    }
    

    func loadSession() async {
        
        do {
            self.isLoading = true
            let currentSession = try await SupabaseHandler.client.auth.session
            
            self.session = currentSession
            
            let token = currentSession.accessToken

            guard let data = await getUser(token: token) else {
                if let cachedUser = loadCachedUser(){
                    self.user = cachedUser
                    self.isAuthenticated = true
                    self.isLoading = false
                    if let userId = cachedUser.id as String? {
                        appDelegate?.uploadToken(userId: userId)
                    }
                    return
                }
                self.isAuthenticated = false
                self.isLoading = false
                return
            }
            
            self.user = try JSONDecoder().decode(AppUser.self, from: data)
            cacheUser(self.user!)
            
            self.isLoading  = false
            self.isAuthenticated = true

            if let userId = user?.id {
                appDelegate?.uploadToken(userId: userId)
            }
            
        } catch {
            // session restore itself failed — try cache
            if let cached = loadCachedUser() {
                self.user = cached
                self.isAuthenticated = true
            } else {
                self.isAuthenticated = false
            }
            self.isLoading = false
        }
        
    }
    
    private func cacheUser(_ user: AppUser){
        if let data = try? JSONEncoder().encode(user){
            UserDefaults.standard.set(data, forKey: "cachedUser")
        }
    }
    
    private func loadCachedUser() -> AppUser? {
        guard let data = UserDefaults.standard.data(forKey: "cachedUser"),
              let user = try? JSONDecoder().decode(AppUser.self, from: data) else {
            return nil
        }
        return user
    }
    
    func logout() {
        self.isAuthenticated = false
        self.isLoading = false
        self.user = nil
        self.session = nil
        UserDefaults.standard.removeObject(forKey: "cachedUser")
    }
    
    func getUser(token: String) async -> Data? {
        
        do {
            var request = URLRequest(
                url: URL(string: "\(SupabaseHandler.backendURL)/users/onboard")!
            )

            request.httpMethod = "GET"

            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )

            let (data, _) = try await URLSession.shared.data(for: request)
            return data
        } catch {
            print(error)
            return nil
        }
        
        
        
    }
    
    func signUp(email: String, password: String) async -> String?{
        do {
            let authResponse = try await SupabaseHandler.client.auth.signUp(
                email: email,
                password: password
            )

            guard let session = authResponse.session else {
                ToastManager.shared.error("Signup failed — no session returned")
                return nil
            }

            let token = session.accessToken

            guard let data = await getUser(token: token) else {
                return nil
            }

            self.user = try JSONDecoder().decode(AppUser.self, from: data)
            self.session = session
            
            
            
            self.isAuthenticated = true
            cacheUser(self.user!)
            ToastManager.shared.success("Account created")
            
            if let userId = user?.id {
                appDelegate?.uploadToken(userId: userId)
            }
            
            return self.user?.id

        } catch let error as AuthError {
            self.errorMessage = error.message
            print(error)
            ToastManager.shared.error(error.message)
            return nil
        } catch {
            self.errorMessage = error.localizedDescription
            ToastManager.shared.error("Signup failed")
            return nil
        }
    }
    
    func completeAuthLogin() async {
        
        do {
            
            let session = try await SupabaseHandler.client.auth.session
            
            let token = session.accessToken

            guard let data = await getUser(token: token) else {
                return
            }

            let decodedUser = try JSONDecoder()
                .decode(AppUser.self, from: data)

            self.user = decodedUser
            self.session = session
            self.isAuthenticated = true
            cacheUser(decodedUser)
            ToastManager.shared.success("Welcome")
            
            appDelegate?.uploadToken(userId: decodedUser.id)
            
        } catch {
            print(error)
            ToastManager.shared.error("Error Logging In")
        }
        
    }
    
    func signIn(email: String, password: String) async {
        do {

            try await SupabaseHandler.client.auth.signIn(
                email: email,
                password: password
            )

            await completeAuthLogin()



        } catch let error as AuthError {
            
            self.errorMessage = error.message
            print(error)
            ToastManager.shared.error("Invalid Credentials")

        } catch {

            self.errorMessage = error.localizedDescription
            ToastManager.shared.error("Invalid Credentials")
        }
    }
    
    
    
    func signInWithGoogle() async {
        do {
            try await SupabaseHandler.client.auth.signInWithOAuth(
                provider: .google,
                redirectTo: URL(string: "caravyn://auth-callback")
            )
            await completeAuthLogin()
        } catch {
            ToastManager.shared.error("Google sign in failed")
            print(error)
        }
    }
    
    func signInWithApple() async {
        do {
            try await SupabaseHandler.client.auth.signInWithOAuth(
                provider: .apple,
                redirectTo: URL(string: "caravyn://auth-callback")
            )
            await completeAuthLogin()
        } catch {
            ToastManager.shared.error("Apple sign in failed")
            print(error)
        }
    }
    
    func sendPasswordReset(email: String) async {
        do {
            try await SupabaseHandler.client.auth.resetPasswordForEmail(
                email,
                redirectTo: URL(string: "caravyn://reset-password")
            )

            ToastManager.shared.success("Check your email for a reset link")
        } catch {
            ToastManager.shared.error("Failed to send reset email")
            print(error)
        }
    }

    func updatePassword(newPassword: String) async {
        do {
            try await SupabaseHandler.client.auth.update(user: UserAttributes(password: newPassword))
            ToastManager.shared.success("Password updated")
        } catch {
            ToastManager.shared.error("Failed to update password")
            print(error)
        }
    }
    
    func changeUsername(newUsername: String) async {
        do {
            try await SupabaseHandler.client.from("profiles")
                .update(["username": newUsername])
                .eq("id", value: self.user!.id)
                .execute()
            
            self.user!.username = newUsername
        } catch {
            ToastManager.shared.error("Failed to update username")
            print(error)
        }
    }
    
    func refreshProfile() async {
        do {
            let fetched: AppUser = try await SupabaseHandler.client
                .from("profiles")
                .select("*")
                .eq("id", value: self.user!.id)
                .single()
                .execute()
                .value
            
            self.user = fetched
            
        } catch {
            ToastManager.shared.error("Failed to refresh page")
            print(error)
        }
    }
}

