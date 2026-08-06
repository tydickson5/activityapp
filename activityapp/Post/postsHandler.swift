//
//  postsHandler.swift
//  activityapp
//
//  Created by Ty Dickson on 5/30/26.
//

import Foundation
internal import Combine
import UIKit
import Supabase
import AVFoundation
import _LocationEssentials

@MainActor
final class PostsHandler: ObservableObject {
    
    @Published var posts: [Post] = []
    @Published var userPosts: [Post] = []
    
    @Published var isLoading: Bool = false
    @Published var isDeleteLoading: Bool = false
    
    @Published var postType: String = "public"
    
    func getPosts(userId: String, friends: [Friend]) async{
        
        do {
            
            if(postType == "friends"){
                //get friends posts
                
            } else {
                print("public posts showing")
                let fetched: [Post] = try await SupabaseHandler.client
                    .from("posts")
                    .select()
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                
                posts.append(contentsOf: fetched)
                print(posts)
            }
            
            
        } catch {
            print(error)
        }
    }
    func imageURL(path: String) -> URL? {
        let cleanPath = path.hasPrefix("post-media/")
            ? String(path.dropFirst("post-media/".count))
            : path

        do {
            return try SupabaseHandler
                .client
                .storage
                .from("post-media")
                .getPublicURL(path: cleanPath)
        } catch {
            print("image url error:", error)
            return nil
        }
    }
    
    func getPost(postId: String) async -> Post? {
        do {
            let posts: [Post] = try await SupabaseHandler.client
                .from("posts")
                .select()
                .eq("id", value: postId)
                .limit(1)
                .execute()
                .value
            
            return posts.first
        } catch {
            print("getPost error:", error)
            return nil
        }
    }
    
    func createImagePost(imageURL: UIImage, userId: String, groupId: String, caption: String, latitude: Double, longitude: Double, isPublicPost: Bool) async throws{
        
        var isHead: Bool = true
        var state = "public"
        
        if(!isTooCloseToExistingPost(latitude: latitude, longitude: longitude)){
            ToastManager.shared.error("Too close to an existing post")
            isHead = false
        }
        
        let postId =
            UUID()
            .uuidString
        
        let filepath = try await uploadImage(image: imageURL, userId: userId, postId: postId)
        
        var request = URLRequest(url: URL(string: "\(SupabaseHandler.backendURL)/posts/create")!)
        
        request.httpMethod = "POST"
            
        var token = try await SupabaseHandler.client.auth.session.accessToken
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        

        let body: [String: Any] = [
            "postId": postId,
            "userId": userId,
            "groupId": groupId,
            "caption": caption,
            "mediaUrl": filepath,
            "mediaType": "image",
            "videoUrl": "",
            "latitude": latitude,
            "longitude": longitude,
            "state": state,
            "isHead": isHead,
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw NSError(domain: "createImagePost", code: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        
        ToastManager.shared.success("Posted!")

        
    }
    
    func createVideoPost(videoURL: URL, thumbnailURL: UIImage, userId: String, groupId: String, caption: String, latitude: Double, longitude: Double, isPublicPost: Bool) async throws{
        print("posting vid")
        
        var isHead: Bool = true
        var state = "public"
        
        if(!isTooCloseToExistingPost(latitude: latitude, longitude: longitude)){
            ToastManager.shared.error("Too close to an existing post")
            isHead = false
        }
        
        
        let postId =
            UUID()
            .uuidString
        
        let filepath = try await uploadImage(image: thumbnailURL, userId: userId, postId: postId)
        let filepathVideo = try await uploadVideo(videoURL: videoURL, userId: userId, postId: postId)
        
        var request = URLRequest(url: URL(string: "\(SupabaseHandler.backendURL)/posts/create")!)
        
        request.httpMethod = "POST"
    
        var token = try await SupabaseHandler.client.auth.session.accessToken
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        

        let body: [String: Any] = [
            "postId": postId,
            "userId": userId,
            "groupId": groupId,
            "caption": caption,
            "mediaUrl": filepath,
            "mediaType": "video",
            "videoUrl": filepathVideo,
            "latitude": latitude,
            "longitude": longitude,
            "state": state,
            "isHead": isHead,
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw NSError(domain: "createImagePost", code: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        ToastManager.shared.success("Posted!")
      
    }
    
    func deletePost(post: Post) async {
        
        isDeleteLoading = true
        
        var request = URLRequest(url: URL(string: "\(SupabaseHandler.backendURL)/posts/delete")!)
        request.httpMethod = "POST"
        
        do {
            let token = try await SupabaseHandler.client.auth.session.accessToken
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "post_id": post.id,
                "post_type": post.media_type,
                "bucket_path": post.media_url!
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code:", httpResponse.statusCode)
                print("Body:", String(data: data, encoding: .utf8) ?? "no body")
            }
            
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                posts.removeAll { $0.id == post.id }
                userPosts.removeAll { $0.id == post.id }
                ToastManager.shared.success("Post deleted")
            } else {
                ToastManager.shared.error("Failed to delete post")
            }
            
        } catch {
            print("Delete error:", error)
            ToastManager.shared.error("Failed to delete post")
        }
        
        isDeleteLoading = false
    }
    
    func uploadImage(image: UIImage, userId: String, postId: String) async throws -> String{
        
        guard let data = image.jpegData(compressionQuality: 0.75)
        else{
            throw NSError(
                        domain: "upload",
                        code: 1
                    )
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
    
    func getVideoUpload(postId: String) async -> String? {
        do {
            let uploads: [Upload] = try await SupabaseHandler.client
                .from("uploads")
                .select()
                .eq("post_id", value: postId)
                .execute()
                .value
            
            return uploads.first?.file_url
            
        } catch {
            print(error)
            return nil
        }
    }
    
    func isTooCloseToExistingPost(latitude: Double, longitude: Double) -> Bool {
        let newLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        for post in posts {
            guard let postLat = post.latitude, let postLon = post.longitude else { continue }
            let existingLocation = CLLocation(latitude: postLat, longitude: postLon)
            let distanceInFeet = newLocation.distance(from: existingLocation) * 3.28084
            
            if distanceInFeet < 25 {
                return true
            }
        }
        return false
    }
    
    func updatePostLikeCount(postId: String, likes: Int){
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            posts[index].post_likes = likes
        }
    }
    
    func getUsersPosts(userId: String) async {
        do{
            let posts: [Post] = try await SupabaseHandler.client
                .from("posts")
                .select("*")
                .eq("user_id", value: userId)
                .order("created_at", ascending: true)
                .execute()
                .value
            
            userPosts = posts
            
            print(posts)
        } catch {
            print(error)
        }
        
    }
}
