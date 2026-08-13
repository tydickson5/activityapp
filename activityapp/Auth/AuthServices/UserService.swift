//
//  AuthService.swift
//  caravyn
//
//  Created by Ty Dickson on 8/12/26.
//

import Supabase
struct UserService {
    
    func getProfile(userId: String) async throws -> AppUser{
        return try await SupabaseHandler.client.from("profiles").select("*").eq("id", value: userId).single().execute().value
    }
    
    func changeUsername(userId: String, newUsername: String) async throws {
        try await SupabaseHandler.client.from("profiles").update(["username": newUsername]).eq("id", value: userId).execute()
    }
    
    func changeDefaultView(userId: String, newView: String) async throws {
        try await SupabaseHandler.client.from("profiles")
            .update(["user_default_view": newView])
            .eq("id", value: userId)
            .execute()
    }
}
