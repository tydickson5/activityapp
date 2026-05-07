//
//  activityappApp.swift
//  activityapp
//
//  Created by Ty Dickson on 5/5/26.
//

import SwiftUI
import Supabase

@main
struct activityappApp: App {
    
    @Environment var supabase = SupabaseClient(
        supabaseURL: URL(string: "https://YOUR_PROJECT.supabase.co")!,
        supabaseKey: "YOUR_ANON_KEY"
    )
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
