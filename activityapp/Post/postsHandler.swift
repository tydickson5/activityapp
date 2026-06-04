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

@MainActor
final class PostsHandler: ObservableObject {
    
    @Published var posts: [Post] = []
    
    
    func getPosts(userId: String, groupId: String) async{
        
        do {
            
            let fetched: [Post] = try await SupabaseHandler.client
                .from("posts")
                .select()
                .eq("group_id", value: groupId)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            posts = fetched
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
    
    func getPost(){
        
    }
    
    func createPost(imageURL: UIImage, userId: String, groupId: String, caption: String, latitude: Double, longitude: Double) async{
        
        do {
            
            let postId =
                UUID()
                .uuidString
            
            let filepath = try await uploadImage(image: imageURL, userId: userId, postId: postId)
            
            var request = URLRequest(url: URL(string: "\(SupabaseHandler.productionBackendURL)/posts/create")!)
            
            request.httpMethod = "POST"
            
            do {
                
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
                    "latitude": latitude,
                    "longitude": longitude,
                ]
                
                request.httpBody = try? JSONSerialization.data(withJSONObject: body)
                

                do {
                    let (data, response) = try await URLSession.shared.data(for: request)
                    
                    print(String(
                        data: data,
                        encoding: .utf8
                    ) ?? "")
                    
                    
                    
                    
                } catch {
                    print(error)
                }
                
                
                
            }
            
        } catch {
            print(error)
        }
        
    }
    
    func deletePost(){
        
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
    
}
