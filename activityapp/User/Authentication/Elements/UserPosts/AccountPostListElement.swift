//
//  AccountPostListElement.swift
//  caravyn
//
//  Created by Ty Dickson on 7/15/26.
//

import SwiftUI

struct AccountPostListElement: View{
    
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var postStore: PostStore

    
    @State var usersPosts: [Post] = []
    
    var body: some View{
        
        ForEach(postStore.userPosts, id: \.id){ (post: Post) in
            AccountPostElement(post: post)
        }

        
    }
}
