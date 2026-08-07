//
//  RecievedFriendRequestRow.swift
//  caravyn
//
//  Created by Ty Dickson on 8/6/26.
//

import SwiftUI

struct RecievedFriendRequestRow: View {

    let friend: FriendRequest

    @EnvironmentObject var authHandler: AuthHandler

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
        }
        .task {
            user = await authHandler.getOtherUserFromId(
                id: friend.user_id
            )
        }
    }
}
