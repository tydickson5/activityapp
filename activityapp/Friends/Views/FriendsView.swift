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
        Button(action:{
            Task{
                await friendHandler.sendFriendRequest(userId: authHandler.user!.id, friendId: "11911829-4c12-4b17-83e3-4563749b4cd4", friendUsername: "test")
            }
        }){
            Text("Test send friend request")
        }
    }
}
