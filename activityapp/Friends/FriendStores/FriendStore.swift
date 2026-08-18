//
//  FriendStore.swift
//  caravyn
//
//  Created by Ty Dickson on 8/15/26.
//

import Foundation
internal import Combine

@MainActor
class FriendStore: ObservableObject {
    
    @Published var friends: [Friend] = []
    @Published var sentFriendRequests: [FriendRequest] = []
    @Published var recievedFriendRequests: [FriendRequest] = []
    
    @Published var isLoading = false
    
    private let friendService: FriendService
    private let friendRequestService: FriendRequestService
    private let backendService: BackendService
    
    init(friendService: FriendService, friendRequestService: FriendRequestService, backendService: BackendService) {
        self.friendService = friendService
        self.friendRequestService = friendRequestService
        self.backendService = backendService
    }
    
    func loadFriendStoreWithUser(userId: String) async {
        do {
            if let sent = try await friendRequestService.loadSentFriendRequests(userId: userId) {
                self.sentFriendRequests = sent
            } else {
                ToastManager.shared.error("Error loading sent friend requests")
                return
            }
            
            if let recieved = try await friendRequestService.loadRecievedFriendRequests(userId: userId) {
                self.recievedFriendRequests = recieved
            } else {
                ToastManager.shared.error("Error loading recieved friend requests")
                return
            }
            
            if let friends = try await friendService.loadFriends(userId: userId) {
                self.friends = friends
            } else {
                ToastManager.shared.error("Error loading friends")
                return
            }
        } catch {
            ToastManager.shared.error("Error")
            return
        }
    }

    func sendFriendRequest(userId: String, friendId: String, friendUsername: String) async {
        
        isLoading = true
        defer {
            isLoading = false
        }
        
        if(friendRequestService.friendRequestSent(friendId: friendId, sentFriendRequests: sentFriendRequests)){
            ToastManager.shared.error("Request already sent")
            return
        }
        if(friendRequestService.friendRequestRecieved(friendId: friendId, recievedFriendRequests: recievedFriendRequests)){
            ToastManager.shared.error("\(friendUsername) sent you a request")
            return
        }
        if(friendService.isFriend(friendId: friendId, friends: friends)){
            ToastManager.shared.error("Already friends")
            return
        }
        
        do {
            guard let newFriendRequest = try await friendRequestService.sendFriendRequestWithSearch(
                userId: userId,
                friendId: friendId,
                friendUsername: friendUsername,
                backendService: backendService
            ) else {
                ToastManager.shared.error("Error sending request")
                return
            }
            
            sentFriendRequests.append(newFriendRequest)
            ToastManager.shared.success("Sent")
            return
        } catch {
            ToastManager.shared.error("Error sending request")
        }
        
    }
    
    func acceptFriendRequest(type: String, friendId: String, userId: String, friendUsername: String, friendRequestId: String) async {
        
        isLoading = true
        defer {
            isLoading = false
        }
        
        do {
            switch type {
            case "search":
                
                if(!friendRequestService.friendRequestRecieved(friendId: friendId, recievedFriendRequests: recievedFriendRequests)){
                    ToastManager.shared.error("Error! Reload page and try again")
                    return
                }
                
                if let newFriend: Friend = try? await friendService.addFriend(friendRequestId: friendRequestId, userId: userId, friendId: friendId, friendUsername: friendUsername, backendService: backendService) {
                    
                    friends.append(newFriend)
                    ToastManager.shared.success("Friend request accepted!")
                }
                
                //delete friend request
                if try await friendRequestService.deleteFriendRequest(friendRequestId: friendRequestId, backendService: backendService) {
                    if let index = sentFriendRequests.firstIndex(where: { $0.id == friendRequestId }) {
                        sentFriendRequests.remove(at: index)
                    }
                } else {
                    ToastManager.shared.error("Error deleting friend request")
                    return
                }
                
            case "share":
                
            default:
                ToastManager.shared.error("Error")
                return
            }
        } catch {
            ToastManager.shared.error("Error")
            return
        }
    }
    
    func deleteFriendRequest(friendRequestId: String, friendId: String) async {
        
        isLoading = true
        defer {
            isLoading = false
        }
        
        if(!friendRequestService.friendRequestSent(friendId: friendId, sentFriendRequests: sentFriendRequests)){
            ToastManager.shared.error("Error! Reload page and try again")
            return
        }
        
        do {
            
            
            if try await friendRequestService.deleteFriendRequest(friendRequestId: friendRequestId, backendService: backendService) {
                if let index = sentFriendRequests.firstIndex(where: { $0.id == friendRequestId }) {
                    sentFriendRequests.remove(at: index)
                }
            } else {
                ToastManager.shared.error("Error deleting friend request")
                return
            }

        } catch {
            ToastManager.shared.error("Error")
            return
        }
    }
    
    func deleteFriend(userId: String, friendId: String) async {
        
        isLoading = true
        defer {
            isLoading = false
        }
        
        if(!friendService.isFriend(friendId: friendId, friends: friends)){
            ToastManager.shared.error("Error! Reload page and try again")
            return
        }
        
        do {
            
            if try await friendService.deleteFriend(userId: userId, friendId: friendId, backendService: backendService) {
                if let index = friends.firstIndex(where: { $0.friend_id == friendId  }) {
                    friends.remove(at: index)
                }
            } else {
                ToastManager.shared.error("Error deleting friend")
            }
        } catch {
            ToastManager.shared.error("Error deleting friend")
            return
        }
    }
    
    func checkForUserInRequestsAndFriends(friendId: String) -> Bool {
        if(friendRequestService.friendRequestSent(friendId: friendId, sentFriendRequests: sentFriendRequests)){
            return true
        }
        if(friendRequestService.friendRequestRecieved(friendId: friendId, recievedFriendRequests: recievedFriendRequests)){
            return true
        }
        if(friendService.isFriend(friendId: friendId, friends: friends)){
            return true
        }
        return false
    }
}
