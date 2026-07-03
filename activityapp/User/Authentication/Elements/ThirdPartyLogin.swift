//
//  ThirdPartyLogin.swift
//  caravyn
//
//  Created by Ty Dickson on 7/3/26.
//

import SwiftUI

struct ThirdPartyLogin: View {
    
    @EnvironmentObject var authHandler: AuthHandler
    
    var body: some View{
        VStack(spacing: 12) {
            // Apple button
            Button {
                Task { await authHandler.signInWithApple() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 18, weight: .medium))
                    Text("Continue with Apple")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundColor(.white)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            // Google button
            Button {
                Task { await authHandler.signInWithGoogle() }
            } label: {
                HStack(spacing: 8) {
                    Image("Google") // add Google's "G" logo to Assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                    Text("Continue with Google")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black.opacity(0.87))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.google)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.horizontal, 24)
        
    }
}
