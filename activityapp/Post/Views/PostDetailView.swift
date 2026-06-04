//
//  PostDetailView.swift
//  activityapp
//
//  Created by Ty Dickson on 6/1/26.
//
import SwiftUI

struct PostDetailView: View {
    
    let post: Post
    
    var groupHandler: GroupsHandler
    
    var body: some View {
        Text(post.caption)
        AsyncImage(
            url: groupHandler
                .postHandler
                .imageURL(
                    path: post.media_url!
                )
        ) { image in

            image
                .resizable()
                .scaledToFill()
                .frame(
                    width: 200,
                    height: 400
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 12
                    )
                )

        } placeholder: {

            ProgressView()
                
        }

    }
}
