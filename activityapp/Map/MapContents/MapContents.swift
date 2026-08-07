//
//  MapContents.swift
//  caravyn
//
//  Created by Ty Dickson on 8/7/26.
//

import SwiftUI
import MapKit

struct MapContents: MapContent {
    let visiblePosts: [(post: Post, isRecent: Bool)]
    let zoomLevel: Double
    let postHandler: PostsHandler
    
    var body: some MapContent {
        ForEach(visiblePosts, id: \.post.id) { entry in
            let post = entry.post
            let showDetail = zoomLevel < 0.30 || entry.isRecent
            
            Annotation("", coordinate: post.coordinate!) {
                PostMapAnnotation(post: post, isRecent: entry.isRecent, showDetail: showDetail, postHandler: postHandler)
            }
            
            if showDetail {
                MapCircle(center: post.coordinate!, radius: 10)
                    .foregroundStyle(Color.dark.opacity(0.3))
            }
        }
    }
}
