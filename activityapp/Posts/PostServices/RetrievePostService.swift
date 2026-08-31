//
//  RetrievePostService.swift
//  caravyn
//
//  Created by Ty Dickson on 8/18/26.
//
import Supabase
import Foundation

struct RetrievePostService {
    
    func loadPublicPosts() async -> [Post]? {
        do {

            let fetched: [Post] = try await SupabaseHandler.client
                .from("posts")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            
            return fetched
            
        } catch {
            print(error)
            return []
        }
    }
    
    func loadFriendPosts(userId: String, friends: [Friend]) async -> [Post]? {
        do{
            let fetchedFriendsPosts: [Post] = try await SupabaseHandler.client
                .from("posts")
                .select()
                .in("user_id", values: friends.map { $0.friend_id })
                .order("created_at", ascending: false)
                .execute()
                .value
            
            return fetchedFriendsPosts
        } catch {
            print(error)
            return []
        }
    }
    
    func loadUserPosts(userId: String) async -> [Post]? {
        do {
            let fetched: [Post] = try await SupabaseHandler.client.from("posts").select("*").eq("user_id", value: userId).order("created_at", ascending: false).execute().value
            
            return fetched
        } catch {
            print(error)
            return []
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
    
    func getPost(postId: String) async -> Post? {
        do {
            let post: Post = try await SupabaseHandler.client.from("posts").select("*").eq("id", value: postId).single().execute().value
            
            return post
        } catch {
            print(error)
            return nil
        }
    }
    
    func getUsersPosts(userId: String) async -> [Post] {
        do {
            let posts: [Post] = try await SupabaseHandler.client.from("posts").select("*").eq("user_id", value: userId).execute().value
            return posts
        } catch {
            return []
        }
    }
    
    //loading for user with lazy load
    func loadUsersPostsPerPage(userId: String, cursor: String?, limit: Int = 20) async -> [Post] {
        do {
            var query = SupabaseHandler.client.from("posts").select("*").eq("user_id", value: userId)
            
            if let cursor {
                query = query.lt("created_at", value: cursor)
            }
            
            let fetched: [Post] = try await query.order("created_at", ascending: false).limit(limit).execute().value
            
            return fetched
        } catch {
            print(error)
            return []
        }
    }
}
