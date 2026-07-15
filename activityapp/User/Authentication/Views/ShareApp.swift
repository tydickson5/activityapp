//
//  ShareApp.swift
//  caravyn
//
//  Created by Ty Dickson on 7/15/26.
//

import SwiftUI

struct ShareAppView: View{
    
    var body: some View{
        VStack{
            HStack(alignment: .top, spacing: 12) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Warning")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.red)

                    Text("The app is currently in beta testing, so please be aware there might be problems with any functions of the app.\n\nThank you for taking the time to use this. Any feedback can be emailed to tydickson255@gmail.com or texted to \n+1 502-794-2034")
                        .font(.caption)
                        .foregroundStyle(Color.red.opacity(0.85))
                }

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.red.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
            .padding(.bottom, 40)
            
            ShareLink(item: "Join Caravyn Beta Testing! https://testflight.apple.com/join/PxBqJVAG"){
                Label("Share App", systemImage: "square.and.arrow.up")
                    .foregroundStyle(Color.lightBlue)
            }
            .tint(Color.lightBlue)

        }
        .padding()
        
    }
}
#Preview {
    ShareAppView()
}
