//
//  Buttons.swift
//  caravyn
//
//  Created by Ty Dickson on 6/16/26.
//

import SwiftUI

struct ButtonsElement: View {
    
    @EnvironmentObject var groupHandler: GroupsHandler
    @EnvironmentObject var authHandler: AuthHandler
    @EnvironmentObject var postHandler: PostsHandler
    @EnvironmentObject var friendHandler: FriendHandler
    var locationManager: LocationHandler
    
    var body: some View {
        VStack(spacing: 12){
            Button(action:{
                Task{
                    await postHandler.getPosts(userId: authHandler.user!.id, friends: friendHandler.friends)
                }
            }){
                Image(systemName: "arrow.clockwise")
                    .frame(width: 15, height: 15)
                    .foregroundStyle(Color.white)
                    .padding()
                    .background(Color.dark.opacity(0.9))
                    .clipShape(Circle())
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            Button(action:{
                locationManager.recenter()
            }){
                Image(systemName: "location")
                    .frame(width: 15, height: 15)
                    .foregroundStyle(Color.white)
                    .padding()
                    .background(Color.dark.opacity(0.9))
                    .clipShape(Circle())
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            Spacer()
            
        }
        .fixedSize()
        .padding(.top, 0)
        .padding(.trailing, 16)

    }
    
}
