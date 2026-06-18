//
//  AccountView.swift
//  caravyn
//
//  Created by Ty Dickson on 6/17/26.
//

import SwiftUI

struct AccountView: View {
    
    @EnvironmentObject var authHandler: AuthHandler
    
    @State var newUsername: String = ""
    
    @State var showAlert = false
    
    var body: some View{
        NavigationStack{
            Form {
                Section("Username"){
                    HStack{
                        Text(authHandler.user!.username)
                            
                    }
                    HStack{
                        TextField("New Username", text: $newUsername)
                            .padding(5)

                        Spacer()
                        Button(action: {
                            Task{
                                await authHandler.changeUsername(newUsername: newUsername)
                                newUsername = ""
                            }
                        }){
                            Text("Update")
                                .tint(.white)
                                .frame(height:1)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.dark)
                                .stroke(Color.dark.opacity(0.5), lineWidth: 2)
                        )
                    }
                    
                }
                Section("Account"){

                    Button(action:{
                        showAlert.toggle()
                    }){
                        HStack{
                            Text("Log out")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .tint(Color.red)
                        
                    }
                    .alert(isPresented: $showAlert){
                        Alert(title: Text("Log out"), message: Text("Are you sure you want to log out?"), primaryButton: .destructive(Text("Log out")){
                            Task{
                                authHandler.logout()
                            }
                        }, secondaryButton: .cancel())
                    }
                }
            }
        }
        
        
        
    }
}
