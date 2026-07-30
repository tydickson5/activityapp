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
            let body: [String: Any] = [
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
    
    func deleteFriendRequest(friendRequestId: String) async {
        
        if(!friendRequests.contains{$0.id == friendRequestId}){
            ToastManager.shared.error("Error")
            return
        }
        
        do {
            let body: [String: Any] = [
                "id": friendRequestId
            ]
            
            guard let request = await loadHttpRequest(
                path: "friends/deleteRequest",
                body: body
            ) else {
                ToastManager.shared.error("Failed to create request")
                return
            }
            
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                friendRequests.removeAll { $0.id == friendRequestId }
                return
            }
            
            ToastManager.shared.error("Error")
            
        } catch {
            print(error)
            ToastManager.shared.error("Error")
        }
    }
    
    func acceptFriendRequest(friendRequestId: String, userId: String, friendId: String, friendUsername: String) async{
        
        //create friend
        do {
            
            let body: [String: Any] = [
                "friendRequestId": friendRequestId,
                "userId": userId,
                "friendId": friendId,
                "friendUsername": friendUsername
            ]
            
            guard let request = await loadHttpRequest(
                path: "friends/acceptRequest",
                body: body
            ) else {
                ToastManager.shared.error("Failed to create request")
                return
            }
            
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }

            let (data, _) =
                try await URLSession.shared.data(
                    for: request
                )
            
            let friend = try JSONDecoder().decode(Friend.self, from: data)
            print(friend)
            
            self.friends.append(friend)
            
            ToastManager.shared.success("Friend added")
            
             
        } catch {
            print(error)
            ToastManager.shared.error("Error")
        }
        
        //delete friend request
        await deleteFriendRequest(friendRequestId: friendRequestId)
        
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
