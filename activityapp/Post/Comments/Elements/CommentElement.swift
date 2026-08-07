//
//  CommentElement.swift
//  caravyn
//
//  Created by Ty Dickson on 7/15/26.
//

import SwiftUI

struct CommentElement: View{
    
    func formattedDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: isoString) else {
            return isoString
        }

        let output = DateFormatter()
        output.dateStyle = .medium
        output.timeStyle = .short

        return output.string(from: date)
    }
    
    @EnvironmentObject var authHandler: AuthHandler
    var commentHandler = CommentHandler()
    
    var comment: Comment
    
    @State var username: String = "Loading..."
    @State var user: AppUser? = nil
    
    var body: some View{
        HStack{
            if let user{
                NavigationLink(destination: OtherUserView(user: user), label:{
                    Text(username)
                        .font(.caption)

                    Spacer()
                    Text(formattedDate(comment.created_at))
                        .font(.caption)
                })
            } else {
                Text("Loading...")
                    .font(.caption)
            }
            
            
        }
        .task{
            user = await authHandler.getOtherUserFromId(id: comment.user_id)!
            username = user!.username
        }
       
    }
}
