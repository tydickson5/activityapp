//
//  PostService.swift
//  caravyn
//
//  Created by Ty Dickson on 8/18/26.
//

import UIKit
import Supabase
import AVFoundation

struct UploadPostService {
    
    func createPost(isImagePost: Bool, postId: String, imageURL: UIImage?, videoURL: URL?, userId: String, groupId: String, caption: String, latitude: Double, longitude: Double, state: String, created_at: String?, backendService: BackendService) async throws -> Post? {
        
        let isHeadofThread = isTooCloseToExistingPost()
        
        var imageFilePath: String
        var filepathVideo: String = ""
        if(isImagePost) {
 
            imageFilePath = try await uploadImage(image: imageURL!, userId: userId, postId: postId)
            
        } else {
            guard let thumbnailURL = generateThumbnail(from: videoURL!) else {
                ToastManager.shared.error("Error loading video thumbnail")
                return nil
            }
            imageFilePath = try await uploadImage(image: thumbnailURL, userId: userId, postId: postId)
            
            filepathVideo = try await uploadVideo(videoURL: videoURL!, userId: userId, postId: postId)
        }
        
        
        
        let body: [String: Any] = [
            "postId": postId,
            "userId": userId,
            "groupId": groupId,
            "caption": caption,
            "mediaUrl": imageFilePath,
            "mediaType": isImagePost ? "image" : "video",
            "videoUrl": filepathVideo,
            "latitude": latitude,
            "longitude": longitude,
            "state": state,
            "isHead": isHeadofThread,
            "created_at": created_at
        ]
        
        guard let request = try await backendService.loadHttpRequest(path: "posts/create", body: body) else {
            ToastManager.shared.error("Error creating post")
            return nil
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw NSError(domain: "createImagePost", code: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        
        let newPost = try JSONDecoder().decode(Post.self, from: data)
        
        return newPost
    }
    
    func uploadImage(image: UIImage, userId: String, postId: String) async throws -> String {
        
        guard let data = image.jpegData(compressionQuality: 0.75) else {
            throw NSError(domain: "upload", code: 1)
        }
        
        let path =
                "\(userId)/\(postId)/\(UUID().uuidString).jpg"
        
        try await SupabaseHandler.client
            .storage
            .from("post-media")
            .upload(
                path,
                data: data
            )
        
        return path
    }
    
    func uploadVideo(videoURL: URL, userId: String, postId: String) async throws -> String {
        
        let data = try Data(contentsOf: videoURL)
        
        let path = "\(userId)/\(postId)/\(UUID().uuidString)video.mov"
        
        try await SupabaseHandler.client
            .storage
            .from("post-media")
            .upload(
                path,
                data: data,
                options: FileOptions(contentType: "video/quicktime")
            )
        
        return path
    }
    
    func generateThumbnail(from videoURL: URL) -> UIImage? {
        
        let asset = AVURLAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        
        guard let cgImage = try? imageGenerator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    func deletePost(post: Post, backendService: BackendService) async throws -> Bool {
        
        guard let mediaURL = post.media_url else { return false }
        let body: [String: Any] = [
            "post_id": post.id,
            "post_type": post.media_type,
            "bucket_path": mediaURL
        ]
        
        guard let request = try await backendService.loadHttpRequest(path: "posts/delete", body: body) else {
            ToastManager.shared.error("Error deleting post")
            return false
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {

            ToastManager.shared.success("Post deleted")
            return true
        } else {
            ToastManager.shared.error("Failed to delete post")
            return false
        }
    }
    
    func isTooCloseToExistingPost() -> Bool{
        return false
    }
}
