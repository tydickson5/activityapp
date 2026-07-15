//
//  LikesHandler.swift
//  caravyn
//
//  Created by Ty Dickson on 7/7/26.
//
import Supabase
import Foundation

struct Like: Codable {
    var id: String
    var user_id: String
    var post_id: String
    var created_at: String
}

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
                "post_likes": likes
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            //update post
            _ = try await SupabaseHandler.client.from("posts").update(["post_likes": likes + 1]).eq("id", value: postId).execute()
            
            
            
        } catch {
            print(error)
        }
        
    }
    
    func unlikePost(postId: String, likes: Int) async {
        
        do {
            
            //update post
            _ = try await SupabaseHandler.client.from("posts").update(["post_likes": likes - 1]).eq("id", value: postId).execute()
            
            //delete like
            _ = try await SupabaseHandler.client.from("post_likes").delete().eq("post_id", value: postId).execute()
            
        } catch {
            print(error)
        }
        
        
    }
}
