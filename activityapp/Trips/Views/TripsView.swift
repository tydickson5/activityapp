//
//  TripsView.swift
//  caravyn
//
//  Created by Ty Dickson on 8/23/26.
//

import SwiftUI

struct TripsView: View {
    
    @State var trips: [Trip] = []
    
    @EnvironmentObject var authStore: AuthStore
    var tripService = TripService()
    
    @State var showEditTripView = false
    @State var tripToShow: Trip? = nil
    
    var body: some View {
        ScrollView{
            VStack {
                ForEach(trips){ trip in
                    HStack {
                        Text(trip.name)
                        Spacer()
                        if(trip.ended_at == nil){
                            EndTripButton(tripId: trip.id){ success in
                                
                                if(success){
                                    print("ended")
                                }
                            }
                        }
                        
                        Button(action: {
                            tripToShow = trip
                        }){
                            Text("Edit")
                        }

                    }
                }
            }
            .task {
                guard let user = authStore.user else {
                    return
                }
                trips = await tripService.getUsersTrips(userId: user.id)
            }
            .sheet(item: $tripToShow) { trip in
                EditTripView(trip: trip, ended: trip.ended_at == nil ? true : false)
            }
            .padding()

        }
        .refreshable{
            guard let user = authStore.user else {
                return
            }
            trips = await tripService.getUsersTrips(userId: user.id)
        }
        
    }
}
