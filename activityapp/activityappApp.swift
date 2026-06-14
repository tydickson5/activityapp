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
                .onOpenURL{ url in
                    if(authHandler.isAuthenticated){
                        
                        Task{
                            let parts = url.pathComponents

                            guard parts.count >= 3 else { return }
                            guard parts[1] == "group" else { return }

                            let groupId = parts[2]
                            
                            await groupHandler.joinGroup(userId: authHandler.user!.id, groupId: groupId)
                        }
                        
                    } else{
                        ToastManager.shared.error("You are not logged in")
                    }
                }
        }
    }
}
