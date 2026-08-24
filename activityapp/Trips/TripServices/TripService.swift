//
//  TripService.swift
//  caravyn
//
//  Created by Ty Dickson on 8/23/26.
//

import Foundation
import Supabase

struct TripService {
    
    func startTrip(userId: String, username: String, name: String, description: String, backendService: BackendService) async -> Trip? {
        
        let body: [String: Any] = [
            "userId": userId,
            "username": username,
            "name": name,
            "description": description
        ]
        
        do {
            
            guard let request = try await backendService.loadHttpRequest(path: "trips/start", body: body) else {
                ToastManager.shared.error("Error starting trip")
                return nil
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            print(response)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                
                throw NSError(domain: "startTrip", code: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            
            let newTrip = try JSONDecoder().decode(Trip.self, from: data)
            
            ToastManager.shared.success("Trip started")
            return newTrip
            
        } catch {
            ToastManager.shared.error("Error starting trip")
            return nil
        }
    }
    
    func endTrip(tripId: String, backendService: BackendService) async -> Bool {
        
        let body: [String: Any] = [
            "tripId": tripId
        ]
        
        do {
            
            guard let request = try await backendService.loadHttpRequest(path: "trips/end", body: body) else {
                ToastManager.shared.error("Error starting trip")
                return false
            }
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw NSError(domain: "startTrip", code: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            
            ToastManager.shared.success("Trip ended")
            return true
            
        } catch {
            ToastManager.shared.error("Error ending trip")
            return false
        }
        
    }
    
    func getTripById(tripId: String) async -> Trip? {
        
        do {
            let fetched: Trip = try await SupabaseHandler.client.from("trips").select().eq("id", value: tripId).single().execute().value
            return fetched
        } catch {
            print(error)
            return nil
        }
    }
    
    func getUsersTrips(userId: String) async -> [Trip] {
        
        do {
            let fetched: [Trip] = try await SupabaseHandler.client.from("trips").select().eq("user_id", value: userId).execute().value
            return fetched
        } catch {
            print(error)
            return []
        }
    }
}
