//
//  EndTripButton.swift
//  caravyn
//
//  Created by Ty Dickson on 8/23/26.
//

import SwiftUI

struct EndTripButton: View {
    
    var tripId: String
    let onComplete: (Bool) -> Void
    
    var tripService = TripService()
    var backendService = BackendService()
    
    var body: some View {
        Button(action: {
            Task {
                let success = await tripService.endTrip(tripId: tripId, backendService: backendService)
                    
                onComplete(success)
            }
        }){
            Image(systemName: "stop.circle.fill")
                .tint(.red)
        }
    }
}
