//
//  AccountPostElement.swift
//  caravyn
//
//  Created by Ty Dickson on 7/15/26.
//

import SwiftUI

struct AccountPostElement: View{
    
    @EnvironmentObject var postHandler: PostsHandler
    
    var post: Post
    
    var body: some View{
        NavigationLink{
            
        } label: {
            
            HStack{
                if let media = post.media_url {
                    AsyncImage(url: postHandler.imageURL(path: media)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 55, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } placeholder: {
                        Text("error")
                    }
                }
                VStack{
                    Text(post.caption)
                    Text(post.created_at)
                }
            }
                
            
        }
        
    }
}
