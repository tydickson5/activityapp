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
                self.isAuthenticated = false
                self.isLoading = false
                return
            }
            
            self.user = try JSONDecoder().decode(AppUser.self, from: data)

            
            self.isLoading  = false
            self.isAuthenticated = true

            if let userId = user?.id {
                appDelegate?.uploadToken(userId: userId)
            }
            
        } catch {
            self.isAuthenticated = false
        }
        
    }
    
    func logout() {
        self.isAuthenticated = false
        self.isLoading = false
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
    
    func signIn(email: String, password: String) async {
        do {

            let session = try await SupabaseHandler.client.auth.signIn(
                email: email,
                password: password
            )

            let token = session.accessToken

            guard let data = await getUser(token: token) else {
                return
            }

            let decodedUser = try JSONDecoder()
                .decode(AppUser.self, from: data)

            self.user = decodedUser
            self.session = session
            self.isAuthenticated = true
            ToastManager.shared.success("Welcome")
            
            appDelegate?.uploadToken(userId: decodedUser.id)



        } catch let error as AuthError {
            
            self.errorMessage = error.message
            print(error)
            ToastManager.shared.error("Invalid Credentials")

        } catch {

            self.errorMessage = error.localizedDescription
            ToastManager.shared.error("Invalid Credentials")
        }
    }
    
    func signUp(email: String, password: String) async {
        do {
            let authResponse = try await SupabaseHandler.client.auth.signUp(
                email: email,
                password: password
            )

            guard let session = authResponse.session else {
                ToastManager.shared.error("Signup failed — no session returned")
                return
            }

            let token = session.accessToken

            guard let data = await getUser(token: token) else {
                return
            }

            self.user = try JSONDecoder().decode(AppUser.self, from: data)
            self.session = session
            
            
            
            self.isAuthenticated = true

            ToastManager.shared.success("Account created")
            
            if let userId = user?.id {
                appDelegate?.uploadToken(userId: userId)
            }

        } catch let error as AuthError {
            self.errorMessage = error.message
            print(error)
            ToastManager.shared.error(error.message)
        } catch {
            self.errorMessage = error.localizedDescription
            ToastManager.shared.error("Signup failed")
        }
    }
}

