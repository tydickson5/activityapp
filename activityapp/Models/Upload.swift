//
//  Upload.swift
//  activityapp
//
//  Created by Ty Dickson on 6/14/26.
//

import Foundation
import CoreLocation

struct Upload: Codable, Identifiable {
    var id: String
    var post_id: String
    var user_id: String
    var file_url: String
    var media_type: String
    var created_at: String
    
}
