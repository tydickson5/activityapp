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
    @Environment(\.appDelegate) var appDelegate
    
    
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
    
    @State private var tappedPostId: String?
    @State private var tappedPost: Post?
    
    var body: some View {
        
        
        if(authHandler.isAuthenticated){
            TabView{
                HomeView(postHandler: groupHandler.postHandler).id(1)
                    .tabItem { Label("Your List", systemImage: "house.fill") }
                    .onAppear{
                        Task{
                            await groupHandler.loadGroups(user: authHandler.user!)

                            print("POST COUNT:", groupHandler.postHandler.posts.count)
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
            .onReceive(NotificationCenter.default.publisher(for: .notificationTapped)) { notification in
                print("🔥 Received notificationTapped")

                if let postId = notification.userInfo?["postId"] as? String {
                    print("🔥 Post ID:", postId)

                    Task {
                        let post = await groupHandler.postHandler.getPost(postId: postId)
                        print("🔥 Post:", post as Any)

                        if let post {
                            tappedPost = post
                        }
                    }
                }
            }
            .sheet(item: $tappedPost) { post in
                PostDetailView(post: post, groupHandler: groupHandler)
            }

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
