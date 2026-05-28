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
    @EnvironmentObject var groupHandler: GroupsHandler

    
    var body: some View {
        
        
        if(authHandler.isAuthenticated){
            TabView{
                HomeView().id(1)
                    .tabItem { Label("Your List", systemImage: "house.fill") }
                    .onAppear{
                        Task{
                            await groupHandler.loadGroups(userId: authHandler.user!.id)
                        }
                    }
                GroupView()
                    .tabItem { Label("Groups",
                        systemImage: "person.2.fill")}
                    .environmentObject(groupHandler)
            }
            .tint(Color.dark)
        }
        else{
            if(authHandler.isLoading){
                Text("Loading...")
                Button("Back"){
                    authHandler.logout()
                }
            }
            else{
                LoginView()
            }
        }
         
    }
}
