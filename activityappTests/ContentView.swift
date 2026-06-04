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
    @EnvironmentObject var postHandler: PostsHandler
    @EnvironmentObject var locationHandler: LocationHandler
    
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
                    .environmentObject(groupHandler)
                GroupView()
                    .tabItem { Label("Groups",
                        systemImage: "person.2.fill")}
                    .environmentObject(groupHandler)
                PostView()
                    .tabItem { Label("Posts",
                        systemImage: "plus")}
                    .environmentObject(groupHandler)
                    .environmentObject(postHandler)
                    .environmentObject(locationHandler)
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
