//
//  PostStore.swift
//  caravyn
//
//  Created by Ty Dickson on 8/18/26.
//

internal import Combine
import UIKit
import Supabase

@MainActor
class PostStore: ObservableObject {
    
    @Published var publicPosts: [Post] = []
    @Published var friendPosts: [Post] = []
    @Published var userPosts: [Post] = []
    
    @Published var postType: String = "public"
    
    @Published var isLoading: Bool = false
    @Published var isDeleteLoading: Bool = false
    
    private var uploadPostService: UploadPostService
    private var retrievePostService: RetrievePostService
    private var backendService: BackendService
    
    init(uploadPostService: UploadPostService, retrievePostService: RetrievePostService, backendService: BackendService) {
        self.uploadPostService = uploadPostService
        self.retrievePostService = retrievePostService
        self.backendService = backendService
    }

    func loadPosts(userId: String, friends: [Friend]) async {
        if let loadedPublicPosts = await retrievePostService.loadPublicPosts() {
            self.publicPosts = loadedPublicPosts
        } else {
            ToastManager.shared.error("Error loading posts")
            return
        }
        
        if let loadedFriendPosts = await retrievePostService.loadFriendPosts(userId: userId, friends: friends) {
            self.friendPosts = loadedFriendPosts
        } else {
            ToastManager.shared.error("Error loading posts")
            return
        }
        
        if let loadedUserPosts = await retrievePostService.loadUserPosts(userId: userId) {
            self.userPosts = loadedUserPosts
        } else {
            ToastManager.shared.error("Error loading posts")
            return
        }
        
        friendPosts.append(contentsOf: userPosts)
    }
    
    func loadUserPosts(userId: String) async {
        if let loadedUserPosts = await retrievePostService.loadUserPosts(userId: userId) {
            self.userPosts = loadedUserPosts
        } else {
            ToastManager.shared.error("Error loading posts")
            return
        }
    }
    
    func createPost(isImagePost: Bool, postId: String, imageURL: UIImage?, videoURL: URL?, userId: String, groupId: String, caption: String, latitude: Double, longitude: Double, state: String, created_at: String?) async {
        isLoading = true
        defer {
            isLoading = false
        }
        
        do {
            if let newPost = try await uploadPostService.createPost(isImagePost: isImagePost, postId: postId, imageURL: imageURL, videoURL: videoURL, userId: userId, groupId: groupId, caption: caption, latitude: latitude, longitude: longitude, state: state, created_at: created_at ?? nil, backendService: backendService) {
                if(state == "friends") {
                    friendPosts.append(newPost)
                } else {
                    publicPosts.append(newPost)
                }
                userPosts.append(newPost)
            } else {
                ToastManager.shared.error("Error creating post")
                return
            }
            
        } catch {
            print(error)
            ToastManager.shared.error("Error creating post")
            return
        }
    }
    
    func deletePost(post: Post) async {
        isDeleteLoading = true
        defer {
            isDeleteLoading = false
        }
        
        do {
            let deleted = try await uploadPostService.deletePost(post: post, backendService: backendService)
        } catch {
            ToastManager.shared.error("Error deleting post")
            return
        }
    }
    
    func updatePostLikes(post: Post, newLikes: Int) {
        guard let index = publicPosts.firstIndex(where: { $0.id == post.id }) else {
                return
        }

        publicPosts[index].post_likes = newLikes
        
        guard let index = friendPosts.firstIndex(where: { $0.id == post.id }) else {
                return
        }

        friendPosts[index].post_likes = newLikes
        
        guard let index = userPosts.firstIndex(where: { $0.id == post.id }) else {
                return
        }

        userPosts[index].post_likes = newLikes
    }
}
