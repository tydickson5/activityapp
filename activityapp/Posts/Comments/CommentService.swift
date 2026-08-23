//
//  CommentService.swift
//  caravyn
//
//  Created by Ty Dickson on 8/20/26.
//

import Supabase
import Foundation
struct CommentService {
    
    func getPostComments(postId: String) async -> [Comment] {
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
    
    func addComment(postId: String, userId: String, comment: String, backendService: BackendService) async -> Comment? {
        do {
            let body: [String: Any] = [
                "user_id": userId,
                "post_id": postId,
                "comment": comment
            ]
            
            guard let request = try await backendService.loadHttpRequest(path: "comments/create", body: body) else {
                ToastManager.shared.error("Error creating comment")
                return nil
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            let newComment = try? JSONDecoder().decode(Comment.self, from: data)
            
            return newComment
            
        } catch {
            ToastManager.shared.error("Error creating comment")
            return nil
        }
    }
    
    func deleteComment(commentId: String) async -> Bool {
        do {
            _ = try await SupabaseHandler.client.from("post_comments").delete().eq("id", value: commentId).execute()
            
            return true
        } catch {
            ToastManager.shared.error("Error deleting comment")
            return false
        }
    }
}
