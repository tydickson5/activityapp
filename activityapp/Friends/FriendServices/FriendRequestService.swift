//
//  FriendRequestService.swift
//  caravyn
//
//  Created by Ty Dickson on 8/15/26.
//

// TODO: sendFriendRequestWithShare

import Foundation
import Supabase

struct FriendRequestService {
    
    func loadSentFriendRequests(userId: String) async throws -> [FriendRequest]? {
        
        let fetched: [FriendRequest]? = try await SupabaseHandler.client.from("friend_request").select("*").eq("user_id", value: userId).execute().value
        
    
        return fetched
    }
    
    func loadRecievedFriendRequests(userId: String) async throws -> [FriendRequest]? {
        let fetched: [FriendRequest] = try await SupabaseHandler.client
            .from("friend_request")
            .select("*")
            .eq("friend_id", value: userId)
            .execute()
            .value
        
        return fetched
    }
    
    func sendFriendRequestWithSearch(userId: String, friendId: String, friendUsername: String, backendService: BackendService) async throws -> FriendRequest? {
        
        let body: [String: Any] = [
            "userId": userId,
            "friendId": friendId,
            "friendUsername": friendUsername
        ]
        
        guard let request = try await backendService.loadHttpRequest(path: "friends/sendRequest", body: body) else {
            return nil
        }
        
        let (data, _) =
            try await URLSession.shared.data(
                for: request
            )
        
        let friendRequest = try JSONDecoder().decode(FriendRequest.self, from: data)
        
        return friendRequest
    }
    
    func acceptFriendRequestFromSearch() async throws {
        
    }
    
    func acceptFriendRequestFromShare() async throws {
        
    }
    
    func deleteFriendRequest(friendRequestId: String, backendService: BackendService) async throws -> Bool {
        
        let body: [String: Any] = [
            "friendRequestId": friendRequestId
        ]
        
        guard let request = try await backendService.loadHttpRequest(path: "friends/deleteRequest", body: body) else {
            return false
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            return true
        }
        
        return false
    }
    
    func friendRequestSent(friendId: String, sentFriendRequests: [FriendRequest]) -> Bool {
        if(sentFriendRequests.contains{$0.friend_id == friendId}){
            return true
        }
        return false
    }
    
    func friendRequestRecieved(friendId: String, recievedFriendRequests: [FriendRequest]) -> Bool {
        if(recievedFriendRequests.contains{$0.user_id == friendId}){
            return true
        }
        return false
    }
}
