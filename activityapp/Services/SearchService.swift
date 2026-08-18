//
//  SearchService.swift
//  caravyn
//
//  Created by Ty Dickson on 8/17/26.
//
import Supabase

struct SearchService {
    
    func searchUsers(query: String) async throws  -> [AppUser] {
        try await SupabaseHandler.client
            .from("profiles")
            .select()
            .ilike("username", pattern: "%\(query)%")
            .limit(20)
            .execute()
            .value
    }
}
