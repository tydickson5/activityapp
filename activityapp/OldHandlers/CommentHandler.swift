//
//  CommentHandler.swift
//  caravyn
//
//  Created by Ty Dickson on 7/7/26.
//
import Supabase
import Foundation

final class CommentHandler {
    
    
    
    func getComments(postId: String) async -> [Comment] {
        
        do {
            
            let fetched: [Comment] = try await SupabaseHandler.client
                .from("post_comments")
                .select()
                .eq("post_id", value: postId)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            return fetched
        } catch {
            print(error)
            return []
        }
    }
    
    func addComment(userId: String, postId: String, comment: String, comments: [Comment]) async -> [Comment]{
        do {
            
            if(comment == ""){
                ToastManager.shared.error("Add a comment")
                return comments
            }
            
            var request = URLRequest(url: URL(string: "\(SupabaseHandler.backendURL)/comments/create")!)
            
            request.httpMethod = "POST"
            
            var token = try await SupabaseHandler.client.auth.session.accessToken
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "user_id": userId,
                "post_id": postId,
                "comment": comment
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            let newComment = try? JSONDecoder().decode(Comment.self, from: data)
            
            return comments + [newComment!]
            
        } catch {
            print(error)
            return comments
        }
    }
    
    func deleteComment(commentId: String, comments: [Comment]) async  -> [Comment]{
        
        do{
            var newComments = comments
            
            
            
            _ = try await SupabaseHandler.client.from("post_comments").delete().eq("id", value: commentId).execute()
            
            return comments.filter { $0.id != commentId }
            
        } catch {
            print(error)
            return comments
        }
        return comments
    }
    
}
