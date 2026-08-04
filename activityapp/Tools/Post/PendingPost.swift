//
//  PendingPost.swift
//  caravyn
//
//  Created by Ty Dickson on 8/4/26.
//

import Foundation

struct PendingPost: Codable, Identifiable {
    let id: String
    let user_id: String
    let group_id: String
    let caption: String
    let media_url: String? //filename
    let media_type: String //type image or video
    let latitude: Double?
    let longitude: Double?
    var post_likes: Int = 0
    let public_post: Bool
    var attempts : Int = 0
    let thumbnailFilename: String?
    
}
