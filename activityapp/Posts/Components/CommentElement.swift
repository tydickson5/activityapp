//
//  CommentElement.swift
//  caravyn
//
//  Created by Ty Dickson on 8/21/26.
//

import SwiftUI

struct CommentElement: View {
    
    @EnvironmentObject var authStore: AuthStore
    var userService = UserService()
    var dateFormatterService = DateFormatterService()
    
    var comment: Comment
    
    @State var otherUser: AppUser? = nil
    
    var body: some View {
        HStack {
            if let otherUser {
                NavigationLink(destination: OtherUserView(user: otherUser), label: {
                    Text(otherUser.username)
                        .font(.caption)
                    Spacer()
                    Text(dateFormatterService.formattedDate(comment.created_at))
                        .font(.caption)
                })
            }
        }
        .task {
            do {
                otherUser = try await userService.getProfile(userId: comment.user_id)
            } catch {
                print(error)
            }
            
        }
    }
}
