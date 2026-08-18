//
//  SentFriendRequestRow.swift
//  caravyn
//
//  Created by Ty Dickson on 8/17/26.
//

import SwiftUI

struct SentFriendRequestRow: View {
    
    @EnvironmentObject var friendStore: FriendStore
    var userService: UserService
    
    var request: FriendRequest
    
    @State private var user: AppUser?
    
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
            Button {
                Task {
                    await friendStore.deleteFriendRequest(friendRequestId: request.id, friendId: request.friend_id)
                }
            } label: {
                Image(systemName: "trash.fill")
                    .foregroundStyle(Color.red)
            }
            .buttonStyle(.borderless)
            .disabled(friendStore.isLoading)
        }
        .task {
            do {
                user = try await  userService.getProfile(userId: request.friend_id)
            } catch {
                ToastManager.shared.error("Error loading page")
            }
        }
    }
}
