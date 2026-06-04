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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    
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
                .toast()
        }
    }
}
