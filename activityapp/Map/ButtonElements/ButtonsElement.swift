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
    var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 12){
            GroupPillSelectorElement()
            Button(action:{
                Task{
                    await postHandler.getPosts(userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!)
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
