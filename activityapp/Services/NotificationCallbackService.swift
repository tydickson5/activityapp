//
//  NotificationCallbackService.swift
//  caravyn
//
//  Created by Ty Dickson on 8/13/26.
//

import Foundation
import Supabase

struct NotificationCallbackService {
    
    func authCallback(url: URL) async throws {
        try await SupabaseHandler.client.auth.session(from: url)
        print("Auth callback complete")
    }
}
