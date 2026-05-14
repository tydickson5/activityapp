//
//  ContentView.swift
//  activityapp
//
//  Created by Ty Dickson on 5/5/26.
//

import SwiftUI
import Supabase

struct ContentView: View {
    
    @Environment(\.appEnvironment) var env
    
    var client: SupabaseClient {
        SupabaseClient(
            supabaseURL: URL(string: env.supabaseUrl)!,
            supabaseKey: env.supabaseAnonKey
        )
    }
    
    var body: some View {
        LoginView()
    }
}

#Preview {
    ContentView()
}
