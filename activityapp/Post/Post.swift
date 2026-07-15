//
//  Post.swift
//  activityapp
//
//  Created by Ty Dickson on 6/1/26.
//
import Foundation
import CoreLocation

struct Post: Codable, Identifiable {
    var id: String
    var user_id: String
    var group_id: String
    var caption: String
    var media_url: String?
    var media_type: String
    var latitude: Double?
    var longitude: Double?
    var created_at: String
    var post_likes: Int
    
    var coordinate: CLLocationCoordinate2D?{
        guard let latitude, let longitude else{
            return nil
        }
        
        return CLLocationCoordinate2D(latitude: latitude,longitude: longitude)
    }
}
