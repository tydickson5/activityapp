//
//  LikesHandler.swift
//  caravyn
//
//  Created by Ty Dickson on 7/7/26.
//
import Supabase
import Foundation


final class LikesHandler {
    
    func getLikes(postId: String) async -> [Like] {
        
        do{
            //get list of users who liked post
            let fetched: [Like] = try await SupabaseHandler.client
                .from("post_likes")
                .select()
                .eq("post_id", value: postId)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            return fetched
        } catch {
            print(error)
            ToastManager.shared.error("Error loading")
            return []
        }
        
        
    }
    
    func checkUserLikeOnPost(postId: String, userId: String) async -> Bool {
        
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
    
    func likePost(postId: String, likes: Int, userId: String) async {
        
        
        do {
            print("trying")
            //create like hit backend
            var request = URLRequest(url: URL(string: "\(SupabaseHandler.backendURL)/likes/create")!)
            
            request.httpMethod = "POST"
            let token = try await SupabaseHandler.client.auth.session.accessToken
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "postId": postId,
                "userId": userId,
                "postLikes": likes
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            
            
        } catch {
            print(error)
        }
        
    }
    
    func unlikePost(postId: String, userId: String, likes: Int) async {
        
        do {
            
            var request = URLRequest(url: URL(string: "\(SupabaseHandler.backendURL)/likes/delete")!)
            
            request.httpMethod = "POST"
            let token = try await SupabaseHandler.client.auth.session.accessToken
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "postId": postId,
                "userId": userId,
                "postLikes": likes
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            
        } catch {
            print(error)
        }
        
        
    }
}
