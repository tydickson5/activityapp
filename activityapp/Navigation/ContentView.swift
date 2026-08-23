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
    
    var retrievePostService = RetrievePostService()
    
    var client: SupabaseClient {
        SupabaseClient(
            supabaseURL: URL(string: env.supabaseUrl)!,
            supabaseKey: env.supabaseAnonKey
        )
    }
    
    func processPostNotification(postId: String) {
        print("🔥 Processing:", postId)

        Task {
            if let post = await retrievePostService.getPost(postId: postId) {
                print("🔥 Found post:", post.id)

                await MainActor.run {
                    navigationHandler.selectedPost = post
                    appDelegate.pendingPostId = nil
                }
            } else {
                print("🔥 Failed to load post")
            }
        }
    }
    
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var groupHandler: GroupsHandler
    @EnvironmentObject var postStore: PostStore
    @EnvironmentObject var locationHandler: LocationHandler
    @EnvironmentObject var navigationHandler: NavigationHandler
    @EnvironmentObject var friendStore: FriendStore
    
    @State var userView = 0
    
    var body: some View {
        
        
        if authStore.isAuthenticated, let user = authStore.user{
            if(authStore.needsOnboarding){
                PermissionsOnboardView(onComplete: {
                    authStore.needsOnboarding = false
                    })
                    .environmentObject(authStore)
                    .environmentObject(locationHandler)
            } else {
                TabView(selection: $userView){
                    HomeView().id(1)
                        .tabItem { Label("Map", systemImage: "map.fill") }
                        .tag(0)

                    
                    NewPostView()
                        .tabItem { Label("Posts",
                            systemImage: "plus")}
                        .tag(1)
                        .environmentObject(postStore)
                        .environmentObject(authStore)
                        .environmentObject(locationHandler)

                    FriendsView()
                        .tabItem { Label("Friends",systemImage: "person")
                        }
                        .tag(2)
                        .environmentObject(friendStore)
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
                    Task{
                        await friendStore.loadFriendStoreWithUser(userId: user.id)
                        
                        await postStore.loadPosts(userId: user.id, friends: friendStore.friends)

                    }
                    
                    PostUploadQueue.shared.postStore = postStore
                    PostUploadQueue.shared.retryAll()
                }
                .onChange(of: authStore.isAuthenticated) { _, authenticated in
                    guard authenticated else { return }

                    if let postId = appDelegate.pendingPostId {
                        processPostNotification(postId: postId)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .notificationTapped)) { notification in
                    print("🔥 Received notificationTapped")
                    print(notification.userInfo ?? [:])

                    let postId =
                        notification.userInfo?["postId"] as? String ??
                        notification.userInfo?["post_id"] as? String

                    print("🔥 Extracted postId:", postId ?? "nil")

                    if let postId {
                        processPostNotification(postId: postId)
                    }
                }
                .sheet(item: $navigationHandler.selectedPost) { post in
                    PostDetailView(post: post)
                }
                .task {
                    if(authStore.user!.user_default_view == "home"){
                        userView = 0
                    } else {
                        userView = 1
                    }
                }
            }
            

        }
        else{
            if(authStore.isLoading){
                Text("Loading...")
                    .padding(.bottom, 5)
                Button(action:{
                    authStore.logOut()
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
