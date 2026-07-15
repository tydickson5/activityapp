//
//  DefaultView.swift
//  caravyn
//
//  Created by Ty Dickson on 7/10/26.
//

import SwiftUI

struct DefaultView: View {
    
    @EnvironmentObject var authHandler: AuthHandler
    
    var body: some View{
        HStack{
            if(authHandler.user?.user_default_view == "home"){
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.lightBlue)
            }
            Text("Map")
            Spacer()
            Image(systemName: "chevron.right")
        }
        .onTapGesture {
            Task{
                await authHandler.updateDefaultView(view: "home")
            }
        }
        HStack{
            if(authHandler.user?.user_default_view == "image"){
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.lightBlue)
            }
            Text("Image Post")
            Spacer()
            Image(systemName: "chevron.right")
        }
        .onTapGesture {
            Task{
                await authHandler.updateDefaultView(view: "image")
            }
        }
        HStack{
            if(authHandler.user?.user_default_view == "video"){
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.lightBlue)
            }
            Text("Video Post")
            Spacer()
            Image(systemName: "chevron.right")
        }
        .onTapGesture {
            Task{
                await authHandler.updateDefaultView(view: "video")
            }
        }
    }
}
