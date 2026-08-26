//
//  Trip.swift
//  caravyn
//
//  Created by Ty Dickson on 8/24/26.
//

struct Trip: Decodable, Identifiable {
    var id: String
    var user_id: String
    var name: String
    var description: String
    var created_at: String
    var ended_at: String?
}
