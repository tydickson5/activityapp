//
//  DefaultView.swift
//  caravyn
//
//  Created by Ty Dickson on 7/10/26.
//

import SwiftUI

struct DefaultView: View {
    
    @EnvironmentObject var authStore: AuthStore
    var userService = UserService()
    
    var body: some View{
        HStack{
            if(authStore.user?.user_default_view == "home"){
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.lightBlue)
            }
            Text("Map")
            Spacer()
            Image(systemName: "chevron.right")
        }
        .onTapGesture {
            Task{
                do {
                    guard let user = authStore.user else {
                        return
                    }
                    try await  userService.changeDefaultView(userId: user.id, newView: "home")
                    authStore.user?.user_default_view = "home"
                }

            }
        }
        HStack{
            if(authStore.user?.user_default_view == "image"){
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.lightBlue)
            }
            Text("Camera")
            Spacer()
            Image(systemName: "chevron.right")
        }
        .onTapGesture {
            Task{

                do {
                    guard let user = authStore.user else {
                        return
                    }
                    try await  userService.changeDefaultView(userId: user.id, newView: "image")
                    authStore.user?.user_default_view = "image"
                }
            }
        }

    }
}
