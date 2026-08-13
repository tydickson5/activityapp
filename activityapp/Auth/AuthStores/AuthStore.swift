//
//  AuthHandler.swift
//  caravyn
//
//  Created by Ty Dickson on 8/12/26.
//

import SwiftUI
internal import Combine
internal import Auth
import Supabase
internal import System

@MainActor
class AuthStore: ObservableObject {
    
    @Published var user: AppUser?
    @Published var session: Session?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var isLoginLoading = false
    @Published var needsOnboarding: Bool = false
    @Published var errorMessage: String?
    
    private let authService: AuthService
    private let userService: UserService
    private let userCache: UserCache
    private let backendService: BackendService
    weak var appDelegate: AppDelegate?
    
    init(authService: AuthService, userService: UserService, userCache: UserCache, backendService: BackendService){
        self.authService = authService
        self.userService = userService
        self.userCache = userCache
        self.backendService = backendService
    }
    
    //load user session
    func loadSession() async {
        self.isLoading = true
        
        //will always run
        defer{
            self.isLoading = false
        }
        
        do {
            //get current session if online
            let currentSession = try await authService.currentSession()
            session = currentSession
            let fetchedUser = try await backendService.fetchUser(token: currentSession.accessToken)
            loadUser(user: fetchedUser)
            
        } catch {
            if let cachedUser = userCache.loadUser() {
                //if offline load cache
                loadUser(user: cachedUser)
            } else {
                //user not logged in
                isAuthenticated = false
            }
        }
    }
    
    func loadUser(user: AppUser) {
        self.user = user
        isAuthenticated = true
        userCache.saveUser(user)
        appDelegate?.uploadToken(userId: user.id)
        needsOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding_\(user.id)")
    }
    
    //need oauth
    func signIn(provider: String, email: String, password: String) async {
        isLoginLoading = true
        defer { isLoginLoading = false }
        
        do{
            
            switch provider{
            case "google":
                try await authService.signInWithOAuth(provider: .google)
            case "apple":
                try await authService.signInWithOAuth(provider: .apple)
            default:
                try await authService.signIn(email: email, password: password)
            }
            
            
            try await completeLogin()
        } catch {
            errorMessage = error.localizedDescription
            ToastManager.shared.error("Invalid Credentials")
        }
    }
    
    func signUp(email: String, password: String) async{
        isLoginLoading = true
        defer { isLoginLoading = false }
        
        do {
            guard let session = try await authService.signUp(email: email, password: password) else {
                ToastManager.shared.error("Signup failed — no session returned")
                return
            }
            
            let fetchedUser = try await backendService.fetchUser(token: session.accessToken)
            self.session = session
            loadUser(user: fetchedUser)
            ToastManager.shared.success("Account created")
            
        } catch {
            errorMessage = error.localizedDescription
            ToastManager.shared.error("Signup failed")
        }
    }
    
    func completeLogin() async throws{
        let session = try await authService.currentSession()
        let fetchedUser = try await backendService.fetchUser(token: session.accessToken)
        self.session = session
        loadUser(user: fetchedUser)
        ToastManager.shared.success("Welcome")
    }
    
    func logOut(){
        isAuthenticated = false
        user = nil
        session = nil
        userCache.removeUser()
    }
    
    func refreshProfile() async{
        guard let userId = user?.id else { return }
        do {
            user = try await userService.getProfile(userId: userId)
        } catch {
            ToastManager.shared.error("Failed to refresh page")
        }
    }
    
}
