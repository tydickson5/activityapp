//
//  WelcomeOnboardView.swift
//  caravyn
//
//  Created by Ty Dickson on 8/8/26.
//

import SwiftUI

struct WelcomeOnboardView: View {
    
    //@Binding var showWelcomeOnboardView: Bool

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("OnboardBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()

                VStack(alignment: .leading, spacing: 50) {
                    Text("Caravyn")
                        .font(.system(size: 50))
                        .bold()
                        .foregroundStyle(.dark)
                        .padding(.top, 80)

                    Text("Welcome, the goal of this app is to show your travels to people all over the world. We want to provide a way for people to be inspired to travel new places by seeing experiences or photographs.\n\nWe would like to ask that you post only photos from travel or cool experiences as this is not a normal social media platform but more for helping people see specifically the world.\n\nThank you for taking the time to beta test this app. It is very helpful.")
                        .padding()
                        .background(.white.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Button(action: {
                        
                    }) {
                        Text("Continue")
                        Image(systemName: "arrow.right")
                    }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.lightBlue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.bottom,30)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    WelcomeOnboardView()
}
