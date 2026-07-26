//
//  friendsHandler.swift
//  caravyn
//
//  Created by Ty Dickson on 7/23/26.
//

internal import Combine
import Foundation
internal import Auth
import Supabase

@MainActor
final class FriendHandler: ObservableObject {
    
    @Published var friends: [Friend] = []
    @Published var friendRequests: [FriendRequest] = []
    
    
    func loadFriends(){
        
    }
    
    func sendFriendRequest(userId: String, friendId: String, friendUsername: String) async{
        if(friendRequests.contains{$0.user_id == userId && $0.friend_id == friendId}){
            ToastManager.shared.error("Reqeust already sent")
            return
        }
        
        do {
            var body: [String: Any] = [
                "userId": userId,
                "friendId": friendId,
                "friendUsername": friendUsername
            ]
            
            guard let request = await loadHttpRequest(
                path: "friends/sendRequest",
                body: body
            ) else {
                ToastManager.shared.error("Failed to create request")
                return
            }
            
            let (data, _) =
                try await URLSession.shared.data(
                    for: request
                )
            
            let friendRequest = try JSONDecoder().decode(FriendRequest.self, from: data)
            print(friendRequest)
            
            self.friendRequests.append(friendRequest)
            
            ToastManager.shared.success("Request send")
            
        } catch {
            print(error)
            ToastManager.shared.error("Failed to send friend request")
        }
    }
    
    func deleteFriendRequest(){
        
    }
    
    func acceptFriendRequest(){
        
    }
    
    func declineFriendRequest(){
        
    }
    
    func loadHttpRequest(path: String, body: [String: Any]) async -> URLRequest?{
        do {
            let urlString = "\(SupabaseHandler.backendURL)/\(path)"
            print("URL String:", urlString)

            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                return nil
            }
            
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            
            let token = try await SupabaseHandler.client.auth.session.accessToken
            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization")
            
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )
            
            request.httpBody =
                try? JSONSerialization.data(
                    withJSONObject: body
                )
            
            return request
        } catch {
            print(error)
            return nil
        }
    }
    
}
