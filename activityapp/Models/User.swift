//
//  User.swift
//  activityapp
//
//  Created by Ty Dickson on 5/13/26.
//

struct AppUser: Codable, Identifiable {
    var id: String
    var username: String
    var created_at: String
    var selected_group: String
    var user_default_view: String
}
