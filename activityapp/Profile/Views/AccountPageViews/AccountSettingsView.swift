//
//  AccountSettingsView.swift
//  caravyn
//
//  Created by Ty Dickson on 7/15/26.
//

import SwiftUI

struct AccountSettingsView: View {
    
    @EnvironmentObject var authStore: AuthStore
    var userService = UserService()
    
    @State var newUsername: String = ""
    
    @State var showAlert = false
    
    var body: some View{
        
        NavigationStack{
            Form {
                Section("Username"){
                    HStack{
                        Text(authStore.user?.username ?? "")
                        
                    }
                    HStack{
                        TextField("New Username", text: $newUsername)
                            .padding(5)
                        
                        Spacer()
                        Button(action: {
                            Task{
                                if let userId = authStore.user?.id {
                                    await userService.changeUsername(userId: userId, newUsername: newUsername)
                                    newUsername = ""
                                } else {
                                    return
                                }
                                
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
                Section("Default view when openning app"){
                    DefaultView()
                }
                Section("Share app"){
                    HStack{
                        NavigationLink("Share App", destination: ShareAppView())
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
                                authStore.logout()
                            }
                        }, secondaryButton: .cancel())
                    }
                }
            }
        }
    }
}
