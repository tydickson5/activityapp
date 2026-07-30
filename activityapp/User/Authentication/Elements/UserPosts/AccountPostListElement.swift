//
//  AccountPostListElement.swift
//  caravyn
//
//  Created by Ty Dickson on 7/15/26.
//

import SwiftUI

struct AccountPostListElement: View{
    
    @EnvironmentObject var authHandler: AuthHandler
    @EnvironmentObject var postHandler: PostsHandler

    
    @State var usersPosts: [Post] = []
    
    var body: some View{
        
        ForEach(postHandler.userPosts, id: \.id){ (post: Post) in
            AccountPostElement(post: post)
        }
        .task {
            await postHandler.getUsersPosts(userId: authHandler.user!.id)
            print(usersPosts.count)
        }
        
    }
}
