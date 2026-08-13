//
//  AuthService.swift
//  caravyn
//
//  Created by Ty Dickson on 8/12/26.
//

import Foundation
import Supabase

struct AuthService {
    
    func signUp(email: String, password: String) async throws -> Session? {
        let response = try await SupabaseHandler.client.auth.signUp(email: email, password: password)
        return response.session
    }

    func signIn(email: String, password: String) async throws {
        try await SupabaseHandler.client.auth.signIn(email: email, password: password)
    }

    func signInWithOAuth(provider: Provider) async throws {
        let redirectTo = URL(string: "caravyn://auth-callback")
        try await SupabaseHandler.client.auth.signInWithOAuth(provider: provider, redirectTo: redirectTo)
    }

    func currentSession() async throws -> Session {
        try await SupabaseHandler.client.auth.session
    }
    
    func sendPasswordReset(email: String) async throws{
        let redirectTo = URL(string: "caravyn://reset-password")
        
        try await SupabaseHandler.client.auth.resetPasswordForEmail(email, redirectTo: redirectTo)
    }
    
    func updatePassword(newPassword: String) async throws {
        try await SupabaseHandler.client.auth.update(user: UserAttributes(password: newPassword))
    }
}
