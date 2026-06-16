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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authHandler)
                .environmentObject(groupHandler)
                .environmentObject(postHandler)
                .environmentObject(locationHandler)
                .task {
                    await authHandler.loadSession()
                }
                .toast()
                .onAppear {
                    appDelegate.authHandler = authHandler
                    authHandler.appDelegate = appDelegate
                }
                .onOpenURL { url in
                    print("OPEN URL:", url.absoluteString)

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

                    // Group invite logic second
                    guard authHandler.isAuthenticated else {
                        ToastManager.shared.error("You are not logged in")
                        return
                    }

                    Task {
                        let parts = url.pathComponents

                        guard parts.count >= 3 else { return }
                        guard parts[1] == "group" else { return }

                        let groupId = parts[2]

                        await groupHandler.joinGroup(
                            userId: authHandler.user!.id,
                            groupId: groupId
                        )
                    }
                }
                .sheet(isPresented: $showResetPassword) {
                    ResetPasswordView(isPresented: $showResetPassword)
                        .environmentObject(authHandler)
                }
        }
    }
}
