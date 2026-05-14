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
    
    @Published var user : User?
    @Published var session: Session?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(){
        Task{
            await loadSession()
        }
    }
    
    func loadSession() async {
        
        do {
            let currentSession = try await SupabaseHandler.client.auth.session
            
            self.session = currentSession
            
            let token = self.session?.accessToken
            let data = await getUser(token: token!)
            
            self.user = try JSONDecoder().decode(User.self, from: data!)
            
            
            self.isAuthenticated = true
        } catch {
            self.isAuthenticated = false
        }
        
    }
    
    func getUser(token: String) async -> Data? {
        
        do {
            var request = URLRequest(
                url: URL(string: "http://localhost:3000/users/onboard")!
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

            let data = await getUser(token: token)

            print(String(data: data!, encoding: .utf8)!)
            self.user = try JSONDecoder().decode(User.self, from: data!)
            print(self.user!.username)

        } catch {
            print(error)
        }
    }
    
    func signUp(email: String, password: String) async {
        do {
            try await SupabaseHandler.client.auth.signUp(email: email, password: password)
                
            let session = try await SupabaseHandler.client.auth.session
            let token = session.accessToken
            
            var request = URLRequest(url: URL(string:"http://localhost:3000/users/onboard")!)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )

            
            let (data, _) = try await URLSession.shared.data(for: request)
            print(String(data: data, encoding: .utf8)!)
        } catch {
            print(error)
        }
    }

    
}

