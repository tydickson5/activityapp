//
//  PostMapAnnotation.swift
//  caravyn
//
//  Created by Ty Dickson on 8/7/26.
//

// PostMapAnnotation.swift
import SwiftUI
import MapKit

struct PostMapAnnotation: View {
    let post: Post
    let isRecent: Bool
    let showDetail: Bool
    
    let postHandler: PostsHandler
    
    var body: some View {
        if showDetail {
            PostElement(post: post, type: isRecent)
                .id(post.id)
                .environmentObject(postHandler)
        } else {
            Image(systemName: "mappin")
                .font(.title)
                .foregroundStyle(Color.pin)
                .frame(width: 50, height: 50)
        }
    }
}
