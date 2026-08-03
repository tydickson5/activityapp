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
            Form{
                Button(action:{
                    Task{
                        await friendHandler.sendFriendRequest(userId: authHandler.user!.id, friendId: "11911829-4c12-4b17-83e3-4563749b4cd4", friendUsername: "test")
                    }
                }){
                    Text("Test send friend request")
                }
                Text("Sent friend requests")
                List {
                    ForEach(friendHandler.friendRequests) { request in
                        HStack{
                            Text(request.friend_username)
                            Button(action:{
                                Task{
                                    await friendHandler.deleteFriendRequest(friendRequestId: request.id)
                                }
                                
                            }){
                                Text("Delete")
                            }
                        }
                        
                        
                    }
                }
                Text("Recieved friend requests")
                List{
                    ForEach(friendHandler.recievedFriendRequests){ request in
                        HStack{
                            Text(request.id)

                            Button(action: {
                                Task{
                                    await friendHandler.deleteFriendRequest(friendRequestId: request.id)
                                }
                            }){
                                Text("Decline")
                            }
                            Button(action: {
                                Task{
                                    await friendHandler.acceptFriendRequest(friendRequestId: request.id, userId: request.friend_id, friendId: request.user_id, friendUsername: request.friend_username)
                                }
                            }){
                                Text("Accept")
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
                                Text("Delete")
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
