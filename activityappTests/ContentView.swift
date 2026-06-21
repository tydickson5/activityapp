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
                HomeView().id(1)
                    .tabItem { Label("Map", systemImage: "map.fill") }
                    .onAppear{
                        Task{
                            if let groupId = await groupHandler.loadGroups(user: authHandler.user!){
                                await postHandler.getPosts(userId: authHandler.user!.id, groupId: groupId)
                            }
                            
                            print("POST COUNT:", postHandler.posts.count)
                        }
                    }
                    .environmentObject(groupHandler)

                
                PostView()
                    .tabItem { Label("Posts",
                        systemImage: "plus")}
                    .environmentObject(groupHandler)
                    .environmentObject(postHandler)
                    .environmentObject(locationHandler)
                GroupView()
                    .tabItem { Label("Groups",
                        systemImage: "person.2.fill")}
                    .environmentObject(groupHandler)
                AccountView()
                    .tabItem{
                        Label("Account", systemImage: "person.crop.circle.fill")
                    }
            }
            .tint(Color.dark)
            .onReceive(NotificationCenter.default.publisher(for: .notificationTapped)) { notification in
                print("🔥 Received notificationTapped")

                if let postId = notification.userInfo?["postId"] as? String {
                    print("🔥 Post ID:", postId)

                    Task {
                        let post = await postHandler.getPost(postId: postId)
                        print("🔥 Post:", post as Any)

                        if let post {
                            tappedPost = post
                        }
                    }
                }
            }
            .sheet(item: $tappedPost) { post in
                PostDetailView(post: post)
                    
            }

        }
        else{
            if(authHandler.isLoading){
                Text("Loading...")
                    .padding(.bottom, 5)
                Button(action:{
                    authHandler.logout()
                }){
                    HStack{
                        Image(systemName: "arrow.left")
                        Text("Back to Login")
                    }
                    .tint(Color.dark)
                }
            }
            else{
                LoginView()
            }
        }
         
    }
}
