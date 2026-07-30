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
            VStack{
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
                        }
                    }
                }
                
                Text("My friends")
                List{
                    
                }
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
