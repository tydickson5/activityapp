//
//  SignUpView.swift
//  activityapp
//
//  Created by Ty Dickson on 5/13/26.
//

import SwiftUI

struct SignUpView: View{
    
    @State var email = ""
    
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var valid: Bool = false
    
    @EnvironmentObject var authHandler: AuthHandler
    
    var body: some View {
        
        VStack(){
            Text("Create Account")
                .tint(Color.dark)
                .font(.largeTitle)
                
            TextField("Email", text: $email)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.dark.opacity(0.5), lineWidth: 2)
                )

            PasswordCheck(password: $password, confirmPassword: $confirmPassword, valid: $valid)

            Button(action: {
                Task{
                    if(valid){
                        await authHandler.signUp(email: email, password: password)
                    } else {
                        ToastManager.shared.error("Invalid Password")
                    }
                    
                }
            }){
                Text("Sign Up")
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
        .padding()

        
    }
        
        
}

#Preview {
    SignUpView().environmentObject(AuthHandler()).toast()
}
