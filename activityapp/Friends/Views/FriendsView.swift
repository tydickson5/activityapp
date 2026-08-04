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
    
    var body: some View {
        ZStack{
            //searchbar needed
            Form{
                Section("Sent Requests") {
                    ForEach(friendHandler.friendRequests) { request in
                        HStack{
                            Text(request.friend_username)
                            Button(action:{
                                Task{
                                    await friendHandler.deleteFriendRequest(friendRequestId: request.id)
                                }
                                
                            }){
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
                            Text(request.id)
                            Spacer()
                            HStack{
                                Button(action: {
                                    Task{
                                        await friendHandler.deleteFriendRequest(friendRequestId: request.id)
                                    }
                                }){
                                    Image(systemName: "trash.fill")
                                        .foregroundStyle(Color.red)
                                        .padding()
                                }
                                
                                Button(action: {
                                    Task{
                                        await friendHandler.acceptFriendRequest(friendRequestId: request.id, userId: request.friend_id, friendId: request.user_id, friendUsername: request.friend_username)
                                    }
                                }){
                                    Image(systemName: "checkmark.fill")
                                        .foregroundStyle(Color.lightBlue)
                                        .padding()
                                        .padding(.leading, 10)
                                }
                                
                                
                            }
                            
                        }
                    }
                }
                
                Section("My Friends"){
                    ForEach(friendHandler.friends){ friend in
                        HStack{
                            Text(friend.friend_id)
                            Button(action: {
                                Task{
                                    print("deleting")
                                    await friendHandler.deleteFriend(userId: authHandler.user!.id,  friendId: friend.friend_id)
                                }
                            }){
                                Image(systemName: "trash.fill")
                                    .foregroundStyle(Color.red)
                                    .padding()
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
