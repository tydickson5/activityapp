//
//  EditTripView.swift
//  caravyn
//
//  Created by Ty Dickson on 8/23/26.
//

import SwiftUI

struct EditTripView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var trip: Trip
    var ended: Bool
    
    @State var name = ""
    @State var description = ""
    
    @State private var tripStartDate = Date()
    @State private var tripEndDate = Date()
    
    var dateFormatterService = DateFormatterService()
    var backendService = BackendService()
    var tripService = TripService()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack {
                    Text("Trip Name")
                        .font(.footnote)
                    TextField("Trip name", text: $name)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.dark.opacity(0.5), lineWidth: 2)
                        )
                }
                
                VStack{
                    Text("Description")
                        .font(.footnote)
                        
                    TextEditor(text: $description)
                        .frame(height: 150)
                        .padding()
                        
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.dark.opacity(0.5), lineWidth: 2)
                        )
                }
                
                VStack{
                    DatePicker(
                        "Start Date",
                        selection: $tripStartDate,
                        in: ...tripEndDate
                    )
                    if(!ended){
                        DatePicker(
                            "End Date",
                            selection: $tripEndDate,
                            in: tripStartDate...
                        )
                    }
                    
                }
                
                Button(action: {
                    Task {
                        let success = await  tripService.updateTripDetails(tripId: trip.id, name: name, description: description, created_at: dateFormatterService.supabaseDateString(tripStartDate), ended_at: dateFormatterService.supabaseDateString(tripEndDate), backendService: backendService)
                        
                        if(success){
                            dismiss()
                        } else {
                            return
                        }
                    }
                }){
                    Text("Update")
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                        .tint(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.dark)
                        .stroke(Color.dark.opacity(0.5), lineWidth: 2)
                )
            }
            .navigationTitle("Edit Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .padding()
            .onAppear() {
                name = trip.name
                description = trip.description
                
                if let date = dateFormatterService.dateFromSupabase(trip.created_at) {
                    tripStartDate = date
                }
                if(!ended){
                    if let date = dateFormatterService.dateFromSupabase(trip.ended_at!) {
                        tripEndDate = date
                    }
                }
                
            }
        }
    }
}
