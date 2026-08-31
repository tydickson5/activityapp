//
//  CreateTripView.swift
//  caravyn
//
//  Created by Ty Dickson on 8/23/26.
//

import SwiftUI

struct CreateTripView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var isSubmitLoading: Bool = false
    
    @EnvironmentObject var authStore: AuthStore
    var tripService = TripService()
    var backendService = BackendService()
    
    var body: some View {
        
        NavigationStack {
            VStack(spacing: 20) {
                
                VStack(alignment: .leading){
                    TextField("Trip name", text: $name)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.dark.opacity(0.5), lineWidth: 2)
                        )
                }
                VStack(alignment: .leading){
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
                Button(action: {
                    isSubmitLoading = true
                    defer {isSubmitLoading = false}
                    guard let user = authStore.user else {
                        return
                    }
                    Task {
                        if (await tripService.startTrip(userId: user.id, username: user.username, name: name, description: description, backendService: backendService)) != nil {
                            name = ""
                            description = ""
                            dismiss()
                        } else {
                            return
                        }
                    }
                    
                }) {
                    Text("Start")
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
                .disabled(name == "")
                .disabled(isSubmitLoading)
            }
            .navigationTitle("New Trip")
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
        }
    }
}
