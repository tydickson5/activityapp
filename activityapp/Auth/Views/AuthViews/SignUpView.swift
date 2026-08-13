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
            
            EmailTextField(email: $email)

            PasswordCheck(password: $password, confirmPassword: $confirmPassword, valid: $valid)

            SubmitSignInButton(typeLogin: false, email: $email, password: $password, valid: $valid)
            
            
        }
        .padding()

        
    }
        
        
}
