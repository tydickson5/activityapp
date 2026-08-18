//
//  FriendService.swift
//  caravyn
//
//  Created by Ty Dickson on 8/16/26.
//

import Foundation
import Supabase

struct FriendService {
    
    func loadFriends(userId: String) async throws -> [Friend]? {
        let fetched: [Friend] = try await SupabaseHandler.client
            .from("friends")
            .select("*")
            .eq("user_id", value: userId)
            .eq("active", value: true)
            .execute()
            .value
        
        return fetched
    }
    
    func addFriend(friendRequestId: String, userId: String, friendId: String, friendUsername: String, backendService: BackendService) async throws -> Friend? {
        
        let body: [String: Any] = [
            "friendRequestId": friendRequestId,
            "userId": userId,
            "friendId": friendId,
            "friendUsername": friendUsername
        ]
        
        guard let request = try await backendService.loadHttpRequest(
            path: "friends/acceptRequest",
            body: body
        ) else {
            ToastManager.shared.error("Failed to create request")
            return nil
            
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            return nil
            
        }

        let (data, _) =
            try await URLSession.shared.data(
                for: request
            )
        
        let friend = try JSONDecoder().decode(Friend.self, from: data)
        
        return friend
    }
    
    func deleteFriend(userId: String, friendId: String, backendService: BackendService) async throws -> Bool {
        
        let body: [String: Any] = [
            "userId": userId,
            "friendId": friendId
        ]
        
        guard let request = try await backendService .loadHttpRequest(
            path: "friends/deleteFriend",
            body: body
        ) else {
            ToastManager.shared.error("Failed to create request")
            return false
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            return false
            
        }
        
        if (200...299).contains(httpResponse.statusCode) {

            return true
        }
        
        ToastManager.shared.error("Error")
        return false
    }
    
    func isFriend(friendId: String, friends: [Friend]) -> Bool {
        if(friends.contains{$0.friend_id == friendId}){
            return true
        }
        return false
    }
}
