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
    
    @EnvironmentObject var authHandler: AuthHandler
    
    var body: some View {
        LoginView()
        /*
        if(authHandler.isAuthenticated){
            HomeView()
        }
        else{
            if(authHandler.isLoading){
                Text("Loading...")
            }
            else{
                LoginView()
            }
        }
         */
    }
}

