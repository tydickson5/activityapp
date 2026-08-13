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
    @State var valid = true
    
    @State var showForgotPassword = false
    
    @EnvironmentObject var authStore: AuthStore
    
    var body: some View {
        NavigationStack{
            ZStack{
                VStack(){
                    Text("Login")
                        .tint(Color.dark)
                        .font(.largeTitle)
                        
                    EmailTextField(email: $email)
                    
                    PasswordSecureField(password: $password, typeNormal: true)

                    SubmitSignInButton(typeLogin: true, email: $email, password: $password, valid: $valid)
                    
                    NavigationLink {
                        SignUpView()
                    } label: {
                        Text("Create Account")
                            .tint(.lightBlue)
                            .padding(.top, 20)
                    }
                    .padding(.bottom, 5)
                    
                    Button("Forgot Password?") {
                        showForgotPassword = true
                    }
                    .sheet(isPresented: $showForgotPassword) {
                        ForgotPasswordView()
                            .environmentObject(authStore)
                    }
                    .tint(.lightBlue)
                    
                    Text("- Or -")
                        .padding(.top, 10)
                    
                    ThirdPartyLogin()
                    
                    
                }
                
            }
            
        }
        .padding()
        
    }
}

