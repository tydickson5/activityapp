//
//  UserSearchResult.swift
//  caravyn
//
//  Created by Ty Dickson on 8/18/26.
//

import SwiftUI

struct UserSearchResult: View {
    
    @EnvironmentObject var friendStore: FriendStore
    @EnvironmentObject var authStore: AuthStore
    var userService: UserService
    
    var user: AppUser
    
    var searchUser: AppUser
    
    var body: some View {
        
        HStack {
            Text(searchUser.username)
            Spacer()
            if(!friendStore.checkForUserInRequestsAndFriends(friendId: searchUser.id)){
                Button {
                    Task {
                        await friendStore.sendFriendRequest(userId: user.id, friendId: searchUser.id, friendUsername: searchUser.username)
                    }
                } label: {
                    Image(systemName: "person.badge.plus")
                        .foregroundStyle(Color.lightBlue)
                }
            }
        }
    }
}
