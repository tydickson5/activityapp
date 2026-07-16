//
//  AccountPostListElement.swift
//  caravyn
//
//  Created by Ty Dickson on 7/15/26.
//

import SwiftUI

struct AccountPostListElement: View{
    
    @EnvironmentObject var authHandler: AuthHandler

    
    @State var usersPosts: [Post] = []
    
    var body: some View{
        
        ForEach(usersPosts, id: \.id){ (post: Post) in
            AccountPostElement(post: post)
        }
        .task {
            usersPosts = await authHandler.getUsersPosts()
            print(usersPosts.count)
        }
        
    }
}
