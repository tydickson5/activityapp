//
//  SearchFriendsView.swift
//  caravyn
//
//  Created by Ty Dickson on 8/5/26.
//

import SwiftUI

struct SearchFriendsView: View {
    
    @EnvironmentObject var friendHandler: FriendHandler
    @EnvironmentObject var authHandler: AuthHandler
    
    @State private var searchText = ""
    @State private var users: [AppUser] = []
    @State private var searchTask: Task<Void, Never>?
    
    var body: some View {
        
        NavigationStack {
            
            List(users) { user in
                if(user.id != authHandler.user!.id){
                    HStack {
                        Text(user.username)
                        
                        Spacer()
                        
                        Button {
                            Task {
                                // send friend request here
                                await friendHandler.sendFriendRequest(userId: authHandler.user!.id, friendId: user.id, friendUsername: user.username)
                            }
                        } label: {
                            Image(systemName: "person.badge.plus")
                                .foregroundStyle(Color.lightBlue)
                        }
                    }
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
                        users = try await friendHandler.searchUsers(
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
