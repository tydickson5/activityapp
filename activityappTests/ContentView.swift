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
    
    func processPostNotification(postId: String) {
        Task {
            if let post = await postHandler.getPost(postId: postId) {
                await MainActor.run {
                    navigationHandler.selectedPost = post
                    appDelegate.pendingPostId = nil
                }
            }
        }
    }
    
    @EnvironmentObject var authHandler: AuthHandler
    @EnvironmentObject var groupHandler: GroupsHandler
    @EnvironmentObject var postHandler: PostsHandler
    @EnvironmentObject var locationHandler: LocationHandler
    @EnvironmentObject var navigationHandler: NavigationHandler
    
    @State var userView = 0
    
    var body: some View {
        
        
        if authHandler.isAuthenticated, let user = authHandler.user{
            if(authHandler.needsOnboarding){
                PermissionsOnboardView(onComplete: {
                        authHandler.needsOnboarding = false
                    })
                    .environmentObject(authHandler)
                    .environmentObject(locationHandler)
            } else {
                TabView(selection: $userView){
                    HomeView().id(1)
                        .tabItem { Label("Map", systemImage: "map.fill") }
                        .tag(0)
                        .onAppear{
                            Task{
                                if let groupId = await groupHandler.loadGroups(user: user){
                                    await postHandler.getPosts(userId: user.id, groupId: groupId)
                                }
                                
                                print("POST COUNT:", postHandler.posts.count)
                            }
                        }
                        .environmentObject(groupHandler)

                    
                    PostView()
                        .tabItem { Label("Posts",
                            systemImage: "plus")}
                        .tag(1)
                        .environmentObject(groupHandler)
                        .environmentObject(postHandler)
                        .environmentObject(authHandler)
                        .environmentObject(locationHandler)
                    GroupView()
                        .tabItem { Label("Groups",
                            systemImage: "person.2.fill")}
                        .tag(2)
                        .environmentObject(groupHandler)
                    AccountView()
                        .tabItem{
                            Label("Account", systemImage: "person.crop.circle.fill")
                        }
                        .tag(3)
                }
                .tint(Color.dark)
                .onAppear {
                    if let postId = appDelegate.pendingPostId {
                        processPostNotification(postId: postId)
                    }
                    
                }
                .onChange(of: authHandler.isAuthenticated) { _, authenticated in
                    guard authenticated else { return }

                    if let postId = appDelegate.pendingPostId {
                        processPostNotification(postId: postId)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .notificationTapped)) { notification in
                    print("🔥 Received notificationTapped")

                    if let postId = notification.userInfo?["postId"] as? String {
                        print("🔥 Post ID:", postId)
                        processPostNotification(postId: postId)
                    }
                }
                .sheet(item: $navigationHandler.selectedPost) { post in
                    PostDetailView(post: post)
                }
                .task {
                    if(authHandler.user!.user_default_view == "home"){
                        userView = 0
                    } else {
                        userView = 1
                    }
                }
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
