//
//  Friend.swift
//  caravyn
//
//  Created by Ty Dickson on 7/23/26.
//

struct Friend: Codable, Identifiable {
    var id: String
    var user_id: String
    var friend_id: String
    var blocked: Bool
    var active: Bool
    var notifications: Bool
    var created_at: String
}
