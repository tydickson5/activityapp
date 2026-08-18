//
//  FriendsView.swift
//  caravyn
//
//  Created by Ty Dickson on 7/24/26.
//

import SwiftUI

struct FriendsView: View {
    
    @EnvironmentObject var friendStore: FriendStore
    @EnvironmentObject var authHandler: AuthHandler
    var userService = UserService()
    var backendService = BackendService()
    
    @State private var searchText = ""
    @State private var users: [AppUser] = []

    
    var body: some View {
        NavigationStack{
            ZStack{
                /*ShareLink(item: "Accept my friend request https://caravyn.com/friends/\(authHandler.user!.id)") {
                    Label("Send friend request", systemImage: "square.and.arrow.up")
                        .foregroundStyle(Color.lightBlue)
                }*/
                Form{
                    Section{
                        NavigationLink {
                            SearchFriendsView()
                        } label: {
                            Label("Find Friends", systemImage: "magnifyingglass")
                        }
                    }
                    Section("Sent Requests") {
                        ForEach(friendStore.sentFriendRequests) { request in
                            SentFriendRequestRow(userService: userService, request: request)
                        }
                    }
                    Section("Recieved Requests"){
                        ForEach(friendStore.recievedFriendRequests){ request in
                            RecievedFriendRequestRow(userService: userService, request: request)
                        }
                    }
                    
                    Section("My Friends"){
                        ForEach(friendStore.friends){ friend in
                            FriendRow(userService: userService, friend: friend)
                        }
                    }
                }
                
                
                
            }
            .refreshable {
                guard let userId = authHandler.user?.id else {return}
                await friendStore.loadFriendStoreWithUser(userId: authHandler.user!.id)
            }
                    
            if(friendStore.isLoading){
                ProgressView()
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.white)
                    )
                    
            }
        }
        
        
    }
        
    
}
