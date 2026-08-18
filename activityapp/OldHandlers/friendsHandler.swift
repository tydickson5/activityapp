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
    @Published var recievedFriendRequests: [FriendRequest] = []
    
    @Published var isLoading = false
    
    
    func loadFriendHandler(user: AppUser) async{
        await loadFriendRequests(userId: user.id)
        await loadFriends(userId: user.id)
        await loadRecievedFriendRequests(userId: user.id)
    }
    
    func loadFriendRequests(userId: String) async {
        do {
            let response = try await SupabaseHandler.client
                .from("friend_request")
                .select("*")
                .eq("user_id", value: userId)
                .execute()

            let fetched = try JSONDecoder().decode(
                [FriendRequest].self,
                from: response.data
            )

            friendRequests = fetched

        } catch {
            print("Error:", error)
        }
    }
    
    func loadRecievedFriendRequests(userId: String) async {
        do {
            let fetched: [FriendRequest] = try await SupabaseHandler.client
                .from("friend_request")
                .select("*")
                .eq("friend_id", value: userId)
                .execute()
                .value
            
            recievedFriendRequests = fetched
        } catch {
            print(error)
        }
    }
    
    func loadFriends(userId: String) async {
        do {
            let fetched: [Friend] = try await SupabaseHandler.client
                .from("friends")
                .select("*")
                .eq("user_id", value: userId)
                .eq("active", value: true)
                .execute()
                .value
            
            friends = fetched
        } catch {
            print(error)
        }
    }
    
    func sendFriendRequest(userId: String, friendId: String, friendUsername: String) async{
        isLoading = true
        print(friendRequests.count)
        if friendRequests.contains(where: {
            $0.user_id == userId && $0.friend_id == friendId
        }) {
            ToastManager.shared.error("Request already sent")
            isLoading = false
            return
        }
        if friends.contains(where: {
            $0.user_id == userId && $0.friend_id == friendId
        }) {
            ToastManager.shared.error("You are friends")
            isLoading = false
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
            //print(String(data: data, encoding: .utf8) ?? "nil")
            let friendRequest = try JSONDecoder().decode(FriendRequest.self, from: data)
            //print(friendRequest)
            
            self.friendRequests.append(friendRequest)
            
            ToastManager.shared.success("Request send")
            isLoading = false
            
        } catch {
            print(error)
            ToastManager.shared.error("Failed to send friend request")
            isLoading = false
        }
    }
    
    func deleteFriendRequest(friendRequestId: String) async {
        isLoading = true
        if(!friendRequests.contains{$0.id == friendRequestId} && !recievedFriendRequests.contains{$0.id == friendRequestId}){
            ToastManager.shared.error("Error")
            isLoading = false
            return
        }
        
        do {
            let body: [String: Any] = [
                "friendRequestId": friendRequestId
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
                isLoading = false
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                friendRequests.removeAll { $0.id == friendRequestId }
                recievedFriendRequests.removeAll { $0.id == friendRequestId }
                isLoading = false
                return
            }
            
            isLoading = false
        } catch {
            print(error)
            ToastManager.shared.error("Error")
            isLoading = false
        }
    }
    
    func acceptFriendRequest(friendRequestId: String, userId: String, friendId: String, friendUsername: String) async{
        isLoading = true
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
                isLoading = false
                return
                
            }
            
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                isLoading = false
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
            isLoading = false
            
            //delete friend request
            await deleteFriendRequest(friendRequestId: friendRequestId)
            isLoading = false
             
        } catch {
            print("Error", error)
            ToastManager.shared.error("Error")
            isLoading = false
        }
        
        
        
    }
    
    func deleteFriend(userId: String, friendId: String) async {
        isLoading = true
        if(!friends.contains{$0.friend_id == friendId}){
            ToastManager.shared.error("Friend not found")
            return
        }
        
        do{
            
            
            
            let body: [String: Any] = [
                "userId": userId,
                "friendId": friendId
            ]
            
            guard let request = await loadHttpRequest(
                path: "friends/deleteFriend",
                body: body
            ) else {
                ToastManager.shared.error("Failed to create request")
                return
            }
            
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                isLoading = false
                return
                
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                friends.removeAll { $0.friend_id == friendId }
                isLoading = false
                return
            }
            
            ToastManager.shared.error("Error")
            isLoading = false
        } catch {
            print(error)
            ToastManager.shared.error("Error")
            isLoading = false
            return
        }
        
        

        
        
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
    
    func searchUsers(query: String) async throws -> [AppUser] {

        try await SupabaseHandler.client
            .from("profiles")
            .select()
            .ilike("username", pattern: "%\(query)%")
            .limit(20)
            .execute()
            .value
    }
    
    func userContainsFriend(friendId: String) -> Bool {
        if(!friendRequests.contains{$0.friend_id == friendId} && !recievedFriendRequests.contains{$0.user_id == friendId} && !friends.contains{$0.user_id == friendId}){

            return false
        }
        return true
    }
    
    func userIsFriend(friendId: String) -> Bool {
        if(friends.contains{$0.friend_id == friendId}){
            return true
        }
        return false
    }
    
    func requestSent(userId: String) -> Bool {
        if(friendRequests.contains{$0.user_id == userId}){
            return true
        }
        return false
    }
    
    func requestRecieved(friendId: String) -> Bool {
        if(recievedFriendRequests.contains{$0.user_id == friendId}){
            return true
        }
        return false
    }
    
}
