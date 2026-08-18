//
//  ReceivedFriendRequestRow.swift
//  caravyn
//
//  Created by Ty Dickson on 8/17/26.
//

import SwiftUI

struct RecievedFriendRequestRow: View {
    
    @EnvironmentObject var friendStore: FriendStore
    @EnvironmentObject var authStore: AuthStore
    var userService: UserService
    
    @State private var user: AppUser?
    
    var request: FriendRequest
    
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
            
            HStack {
                
                Button(action: {
                    Task {
                        guard let userId = authStore.user?.id else {
                            return
                        }
                        guard let friendUsername = user?.username else {
                            return
                        }
                        await friendStore.acceptFriendRequest(type: "search", friendId: request.friend_id, userId: userId, friendUsername: friendUsername, friendRequestId: request.id)
                    }
                }){
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.lightBlue)
                }
                .buttonStyle(.borderless)
                .padding(.trailing, 10)
                .disabled(friendStore.isLoading)
                
                Button(action: {
                    Task {
                        await friendStore.deleteFriendRequest(friendRequestId: request.id, friendId: request.friend_id)
                    }
                }){
                    Image(systemName: "trash.fill")
                        .foregroundStyle(Color.red)
                }
                .buttonStyle(.borderless)
                .disabled(friendStore.isLoading)
            }
        }
        .task {
            do {
                user = try await userService.getProfile(userId: request.friend_id)
            } catch {
                ToastManager.shared.error("Error loading reqeust")
            }
        }
    }
}
