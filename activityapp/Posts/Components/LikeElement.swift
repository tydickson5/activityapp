//
//  LikeElement.swift
//  caravyn
//
//  Created by Ty Dickson on 8/21/26.
//

import SwiftUI

struct LikeElement: View {
    
    @Binding var post: Post
    @State var liked = false
    
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var postStore: PostStore
    var likeService = LikeService()
    var backendService = BackendService()
    
    var body: some View {
        HStack {
            if(!liked) {
                Button(action: {
                    Task {
                        guard let user = authStore.user else {
                            return
                        }
                        let result = await likeService.likePost(postId: post.id, userId: user.id, currentLikes: post.post_likes, backendService: backendService)
                        print(result)
                        liked = true
                        postStore.updatePostLikes(post: post, newLikes: post.post_likes + 1)
                    }
                }) {
                    Image(systemName: "heart")
                        .foregroundStyle(Color.gray)
                }
            } else {
                Button(action: {
                    Task {
                        guard let user = authStore.user else {
                            return
                        }
                        let result = await likeService.unlikePost(postId: post.id, userId: user.id, currentLikes: post.post_likes, backendService: backendService)
                        print(result)
                        liked = false
                        postStore.updatePostLikes(post: post, newLikes: post.post_likes - 1)
                    }
                }) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(Color.red)
                }
            }
            Text("\(post.post_likes) Likes")
        }
        .task {
            guard let user = authStore.user else {
                print("like returned")
                return
            }
            liked = await likeService.checkForUserLikeOnPost(postId: post.id, userId: user.id)
            print(liked)
        }
    }
}
