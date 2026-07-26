//
//  FriendRequest.swift
//  caravyn
//
//  Created by Ty Dickson on 7/23/26.
//

struct FriendRequest: Codable, Identifiable {
    var id: String
    var user_id: String
    var friend_id: String
    var created_at: String
    var friend_username: String
}
