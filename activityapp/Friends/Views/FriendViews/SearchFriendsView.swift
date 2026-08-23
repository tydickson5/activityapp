//
//  SearchFriendsView.swift
//  caravyn
//
//  Created by Ty Dickson on 8/5/26.
//

import SwiftUI

struct SearchFriendsView: View {
    
    @EnvironmentObject var friendStore: FriendStore
    @EnvironmentObject var authStore: AuthStore
    private var searchService = SearchService()
    private var userService = UserService()
    
    @State private var searchText = ""
    @State private var users: [AppUser] = []
    @State private var searchTask: Task<Void, Never>?
    
    @State private var user: AppUser?
    
    var body: some View {
        
        NavigationStack {
            
            List(users) { searchUser in
                if let user = authStore.user {
                    if(searchUser.id != user.id){
                        UserSearchResult(
                            userService: userService,
                            user: user,
                            searchUser: searchUser
                        )
                    }
                }
                
            }
            .task {
                guard let user = authStore.user else {
                    ToastManager.shared.error("Error loading")
                    return
                }
            }
            .navigationTitle("Find Friends")
            .searchable(text: $searchText)
            .onChange(of: searchText) { _, newValue in
                
                searchTask?.cancel()
                
                searchTask = Task {
                    
                    try? await Task.sleep(
                        for: .milliseconds(300)
                    )
                    
                    guard !Task.isCancelled else {
                        return
                    }
                    
                    let query = newValue.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    
                    if query.isEmpty {
                        users = []
                        return
                    }
                    
                    do {
                        users = try await searchService.searchUsers(
                            query: query
                        )
                    } catch {
                        print("Search error:", error)
                    }
                }
            }
        }
    }
}
