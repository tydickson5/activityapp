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
    
    @State var showForgotPassword = false
    
    @EnvironmentObject var authHandler: AuthHandler
    
    var body: some View {
        NavigationStack{
            VStack(){
                Text("Login")
                    .tint(Color.dark)
                    .font(.largeTitle)
                    
                TextField("Email", text: $email)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.dark.opacity(0.5), lineWidth: 2)
                    )
                SecureField("Password", text: $password)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.dark.opacity(0.5), lineWidth: 2)
                    )

                Button(action: {
                    Task{
                        await authHandler.signIn(email: email, password: password)
                    }
                }){
                    Text("Login In")
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
                
                HStack{
                    Button("google"){
                        Task{
                            await authHandler.signInWithGoogle()
                        }
                    }
                    Button("apple"){
                        Task{
                            await authHandler.signInWithApple()
                        }
                    }
                }
                
                NavigationLink {
                    SignUpView()
                } label: {
                    Text("Create Account")
                        .tint(.lightBlue)
                        .padding(.top, 20)
                }
                .onTapGesture {
                    authHandler.errorMessage = ""
                }
                .padding(.bottom, 5)
                Button("Forgot Password?") {
                    showForgotPassword = true
                }
                .sheet(isPresented: $showForgotPassword) {
                    ForgotPasswordView()
                        .environmentObject(authHandler)
                }
                .tint(.lightBlue)
            }
        }
        .padding()
        
    }
}

