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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    
    let environment = AppEnvironment.live
    
    @State var showResetPassword = false
    
    @StateObject private var authHandler = AuthHandler()
    @StateObject private var groupHandler = GroupsHandler()
    @StateObject private var postHandler = PostsHandler()
    @StateObject private var locationHandler = LocationHandler()
    @StateObject private var navigationHandler = NavigationHandler()
    @StateObject private var friendHandler = FriendHandler()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authHandler)
                .environmentObject(groupHandler)
                .environmentObject(postHandler)
                .environmentObject(locationHandler)
                .environmentObject(navigationHandler)
                .environmentObject(friendHandler)
                .environment(\.appDelegate, appDelegate)
                .task {
                    await authHandler.loadSession()
                }
                .toast()
                .onAppear {
                    appDelegate.authHandler = authHandler
                    authHandler.appDelegate = appDelegate
                }
                .onOpenURL { url in
                    Task{
                        print("OPEN URL:", url.absoluteString)
                        
                        // google/apple auth
                        if(url.host == "auth-callback"){
                            Task {
                                do {
                                    try await SupabaseHandler.client.auth.session(from: url)
                                    print("Apple callback success")
                                } catch {
                                    print("Apple callback error:", error)
                                }
                                
                                await authHandler.completeAuthLogin()
                            }
                            return
                        }

                        // Password reset first
                        if url.host == "reset-password" ||
                           url.absoluteString.contains("type=recovery") {

                            Task {
                                do {
                                    try await SupabaseHandler.client.auth.session(from: url)

                                    await MainActor.run {
                                        showResetPassword = true
                                    }
                                } catch {
                                    print(error)
                                }
                            }

                            return
                        }
                        var waited = 0
                        while authHandler.isLoading && waited < 50 {
                            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                            waited += 1
                        }

                        // Group invite logic second
                        guard authHandler.isAuthenticated else {
                            ToastManager.shared.error("You are not logged in")
                            return
                        }


                        let parts = url.pathComponents

                        guard parts.count >= 3 else { return }
                        guard parts[1] == "group" else { return }

                        let groupId = parts[2]

                        if let groupId = await groupHandler.joinGroup(
                            userId: authHandler.user!.id,
                            groupId: groupId
                        ){
                            authHandler.user?.selected_group = groupId
                            
                            await postHandler.getPosts(userId: authHandler.user!.id, friends: friendHandler.friends)
                        }
                        
                        
                    }
                    
                }
                .sheet(isPresented: $showResetPassword) {
                    ResetPasswordView(isPresented: $showResetPassword)
                        .environmentObject(authHandler)
                }
        }
    }
}
