//
//  Comment.swift
//  caravyn
//
//  Created by Ty Dickson on 8/20/26.
//

struct Comment: Codable, Identifiable {
    var id: String
    var user_id: String
    var post_id: String
    var comment: String
    var created_at: String
}
