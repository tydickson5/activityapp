//
//  Group.swift
//  activityapp
//
//  Created by Ty Dickson on 5/23/26.
//

struct Group: Codable, Identifiable {
    var id: String
    var user_id: String
    var name: String
    var created_at: String
    var post_radius: Int
}
