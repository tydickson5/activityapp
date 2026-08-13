//
//  WelcomeOnboardView.swift
//  caravyn
//
//  Created by Ty Dickson on 8/8/26.
//

import SwiftUI

import SwiftUI

struct WelcomeOnboardView: View {

    @Binding var showWelcomeOnboardView: Bool

    var body: some View {
        ZStack {
            Image("OnboardBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Text("Welcome to Caravyn")
                    .font(.largeTitle)
                    .bold()

                Text("Discover hidden places...")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()

                Button("Continue") {

                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)   // ADD THIS
        }
    }
}


