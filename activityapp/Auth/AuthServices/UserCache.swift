//
//  UserCache.swift
//  caravyn
//
//  Created by Ty Dickson on 8/12/26.
//

import Foundation

struct UserCache {
    
    private let key = "cachedUser"
    
    func saveUser(_ user: AppUser) {
        guard let data = try? JSONEncoder().encode(user) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func loadUser() -> AppUser? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(AppUser.self, from: data)
    }
    
    func removeUser() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
