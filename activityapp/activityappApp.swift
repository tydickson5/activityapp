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

    @StateObject private var authStore = AuthStore(authService: AuthService(), userService: UserService(), userCache: UserCache(), backendService: BackendService())
    @StateObject private var postStore = PostStore(uploadPostService: UploadPostService(), retrievePostService: RetrievePostService(), backendService: BackendService())
    @StateObject private var locationHandler = LocationHandler()
    @StateObject private var navigationHandler = NavigationHandler()
    @StateObject private var friendStore = FriendStore(friendService: FriendService(), friendRequestService: FriendRequestService(), backendService: BackendService())
    
    private var notificationCallbackService = NotificationCallbackService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authStore)
                .environmentObject(postStore)
                .environmentObject(locationHandler)
                .environmentObject(navigationHandler)
                .environmentObject(friendStore)
                .environment(\.appDelegate, appDelegate)
                .task {
                    await authStore.loadSession()
                    authStore.appDelegate = appDelegate
                    appDelegate.authStore = authStore
                    
                    
                }
                .toast()
                .onOpenURL { url in
                    Task{
                        print("OPEN URL:", url.absoluteString)
                        
                        switch url.host{
                        case "auth-callback":
                            do {
                                try await notificationCallbackService.authCallback(url: url)
                                
                            } catch {
                                ToastManager.shared.error("Error")
                            }
                            break
                        case "reset-password":
                            do {
                                try await SupabaseHandler.client.auth.session(from: url)

                                await MainActor.run {
                                    showResetPassword = true
                                }
                            } catch {
                                print(error)
                            }
                            break
                        default:
                            return
                        }

                        /*Password reset first
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
                         */
                        var waited = 0
                        while authStore.isLoading && waited < 50 {
                            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                            waited += 1
                        }

                        // Group invite logic second
                        guard authStore.isAuthenticated else {
                            ToastManager.shared.error("You are not logged in")
                            return
                        }
                    }
                    
                }
                .sheet(isPresented: $showResetPassword) {
                    ResetPasswordView(isPresented: $showResetPassword)
                        .environmentObject(authStore)
                }
        }
    }
}
