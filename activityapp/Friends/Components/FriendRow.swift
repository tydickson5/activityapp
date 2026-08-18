//
//  FriendRow.swift
//  caravyn
//
//  Created by Ty Dickson on 8/17/26.
//

import SwiftUI

struct FriendRow: View {
    
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var friendStore: FriendStore
    var userService: UserService
    
    var friend: Friend
    
    @State var user: AppUser?
    
    var body: some View {
        HStack {
            if let user {
                NavigationLink {
                    OtherUserView(user: user)
                } label: {
                    Text(user.username)
                }
                .buttonStyle(.plain)
            } else {
                Text("Loading...")
            }
            
            Spacer()
            
            Button(action: {
                Task{
                    guard let userId = authStore.user?.id else {
                        return
                    }
                    await friendStore.deleteFriend(userId: userId, friendId: friend.friend_id)
                }
            }){
                Image(systemName: "trash.fill")
                    .foregroundStyle(Color.red)
            }
            .buttonStyle(.borderless)
            .disabled(friendStore.isLoading)
        }
        .task {
            do {
                user = try await userService.getProfile(userId: friend.friend_id)
            } catch {
                ToastManager.shared.error("Error loading friend")
            }
        }
    }
}
