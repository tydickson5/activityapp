//
//  backendService.swift
//  caravyn
//
//  Created by Ty Dickson on 8/12/26.
//

import Foundation
internal import Auth
import Supabase

struct BackendService {
    
    func fetchUser(token: String) async throws -> AppUser {
        var request = URLRequest(url: URL(string: "\(SupabaseHandler.backendURL)/users/onboard")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(AppUser.self, from: data)
    }
    
    func loadHttpRequest(path: String, body: [String: Any]) async throws -> URLRequest? {
        
        let urlString = "\(SupabaseHandler.backendURL)/\(path)"
        print("URL String:", urlString)

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        let token = try await SupabaseHandler.client.auth.session.accessToken
        
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization")
        
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        
        request.httpBody =
            try? JSONSerialization.data(
                withJSONObject: body
            )
        
        return request
    }
    
}
