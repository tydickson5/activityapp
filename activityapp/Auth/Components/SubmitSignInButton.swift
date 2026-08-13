//
//  SubmitSignInButton.swift
//  caravyn
//
//  Created by Ty Dickson on 8/13/26.
//
import SwiftUI

struct SubmitSignInButton: View {
    
    var typeLogin: Bool
    @Binding var email: String
    @Binding var password: String
    @Binding var valid: Bool
    
    @EnvironmentObject var authStore: AuthStore
    
    var body: some View {
        
        Button(action: {
            Task{
                if(typeLogin){
                    await authStore.signIn(provider: "email", email: email, password: password)
                    return
                }
                await authStore.signUp(email: email, password: password)
                
            }
        }){
            Text(typeLogin ? "Login In" : "Sign Up")
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
        .disabled(authStore.isLoginLoading)
        .disabled(!valid)
    }
}
