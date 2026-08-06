//
//  FriendsView.swift
//  caravyn
//
//  Created by Ty Dickson on 7/24/26.
//

import SwiftUI

struct FriendsView: View {
    
    @EnvironmentObject var friendHandler: FriendHandler
    @EnvironmentObject var authHandler: AuthHandler
    
    @State private var searchText = ""
    @State private var users: [AppUser] = []

    
    var body: some View {
        NavigationStack{
            ZStack{
                
                
                //searchbar needed
                
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
                        ForEach(friendHandler.friendRequests) { request in
                            HStack{
                                Text(request.friend_username)
                                Spacer()
                                Button{
                                    Task{
                                        await friendHandler.deleteFriendRequest(friendRequestId: request.id)
                                    }
                                    
                                } label: {
                                    Image(systemName: "trash.fill")
                                        .foregroundStyle(Color.red)
                                        .padding()
                                }
                            }
                            
                            
                        }
                    }
                    Section("Recieved Requests"){
                        ForEach(friendHandler.recievedFriendRequests){ request in
                            HStack{
                                Text(request.friend_username)
                                Spacer()
                                HStack{
                                    Button(action: {
                                        Task{
                                            await friendHandler.deleteFriendRequest(friendRequestId: request.id)
                                        }
                                    }){
                                        Image(systemName: "trash.fill")
                                            .foregroundStyle(Color.red)
                                    }
                                    .buttonStyle(.borderless)
                                    .padding()
                                    
                                    Button(action: {
                                        Task{
                                            await friendHandler.acceptFriendRequest(friendRequestId: request.id, userId: request.friend_id, friendId: request.user_id, friendUsername: request.friend_username)
                                        }
                                    }){
                                        Image(systemName: "checkmark.fill")
                                            .foregroundStyle(Color.lightBlue)

                                    }
                                    .buttonStyle(.borderless)
                                    .padding(.leading, 10)
                                    
                                }
                                
                            }
                        }
                    }
                    
                    Section("My Friends"){
                        ForEach(friendHandler.friends){ friend in
                            HStack{
                                Text(friend.user_id)
                                Spacer()
                                Button(action: {
                                    Task{
                                        print("deleting")
                                        await friendHandler.deleteFriend(userId: authHandler.user!.id,  friendId: friend.friend_id)
                                    }
                                }){
                                    Image(systemName: "trash.fill")
                                        .foregroundStyle(Color.red)
                                }
                            }
                            
                            
                        }
                    }
                }
                
                
                
            }
            .refreshable {
                await friendHandler.loadFriendHandler(user: authHandler.user!)
            }
                    
            if(friendHandler.isLoading){
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
