//
//  LoginView.swift
//  activityapp
//
//  Created by Ty Dickson on 5/10/26.
//
import SwiftUI

struct LoginView: View{
    
    @State var email = ""
    @State var password = ""
    
    @EnvironmentObject var authHandler: AuthHandler
    
    var body: some View {
        
        VStack(){
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            Button(action: {
                Task{
                    await authHandler.signIn(email: email, password: password)
                }
            }){
                Text("Login In")
            }
        }
        VStack(){
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            Button(action: {
                Task{
                    await authHandler.signUp(email: email, password: password)
                }
            }){
                Text("Sign Up")
            }
        }
        Text(authHandler.user?.username ?? "")
        
    }
}

