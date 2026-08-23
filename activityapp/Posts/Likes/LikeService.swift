//
//  LikeService.swift
//  caravyn
//
//  Created by Ty Dickson on 8/20/26.
//

import Supabase
import Foundation
struct LikeService {
    
    func getPostLikes(postId: String) async -> [Like] {
        do{
            let fetched: [Like] = try await SupabaseHandler.client
                .from("post_likes")
                .select()
                .eq("post_id", value: postId)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            return fetched
        } catch {
            ToastManager.shared.error("Error loading")
            return []
        }
    }
    
    func checkForUserLikeOnPost(postId: String, userId: String) async -> Bool {
        do{
            let fetched: [Like] = try await SupabaseHandler.client
                .from("post_likes")
                .select("*")
                .eq("post_id", value: postId)
                .eq("user_id", value: userId)
                .execute()
                .value
            
            if(fetched.isEmpty){
                return false
            }
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func likePost(postId: String, userId: String, currentLikes: Int, backendService: BackendService) async -> Bool {
        do {
            let body: [String: Any] = [
                "postId": postId,
                "userId": userId,
                "postLikes": currentLikes + 1
            ]
            
            guard let request = try await backendService.loadHttpRequest(path: "likes/create", body: body) else {
                ToastManager.shared.error("Error liking post")
                return false
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                return false
            }
            
            return true
            
        } catch {
            ToastManager.shared.error("Error liking post")
            return false
        }
    }
    
    func unlikePost(postId: String, userId: String, currentLikes: Int, backendService: BackendService) async -> Bool{
        do {
            let body: [String: Any] = [
                "postId": postId,
                "userId": userId,
                "postLikes": currentLikes - 1
            ]
            
            guard let request = try await backendService.loadHttpRequest(path: "likes/delete", body: body) else {
                ToastManager.shared.error("Error liking post")
                return false
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                return false
            }
            
            return true

        } catch {
            ToastManager.shared.error("Error unliking post")
            return false
        }
    }
}
