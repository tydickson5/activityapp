//
//  StartTripButton.swift
//  caravyn
//
//  Created by Ty Dickson on 8/23/26.
//

import SwiftUI

struct StartTripButton: View {
    
    @State var createTripSheetPresented: Bool = false
    
    var body: some View {
        VStack {
            Button(action: {
                createTripSheetPresented.toggle()
            }){
                Text("Start Trip")
            }
        }
        .sheet(isPresented: $createTripSheetPresented) {
            CreateTripView()
        }
    }
}
