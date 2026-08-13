//
//  backendService.swift
//  caravyn
//
//  Created by Ty Dickson on 8/12/26.
//

import Foundation

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
    
}
