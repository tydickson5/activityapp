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
    @StateObject var locationManager: LocationManager
    
    var body: some View {
        VStack{
            Menu{
                ForEach(groupHandler.groups){ group in
                    Button {
                        groupHandler.selectedGroup = group.id
                        Task{
                            await groupHandler.updatedSelectedGroup(userId: authHandler.user!.id, groupId: group.id)
                            await groupHandler.postHandler.getPosts(userId: authHandler.user!.id, groupId: group.id)
                        }
                        
                    } label: {
                        Label(
                            group.name,
                            systemImage: group.id == groupHandler.selectedGroup
                                ? "checkmark"
                                : ""
                        )
                        
                    }
                    
                }

            } label: {
                Image(systemName: "chevron.down")
                    .frame(width: 15, height: 15)
                    .foregroundStyle(Color.white)
                    .padding()
                    .background(Color.dark.opacity(0.9))
                    .clipShape(Circle())
            }
            Button(action:{
                Task{
                    await groupHandler.postHandler.getPosts(userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!)
                }
            }){
                Image(systemName: "arrow.clockwise")
                    .frame(width: 15, height: 15)
                    .foregroundStyle(Color.white)
                    .padding()
                    .background(Color.dark.opacity(0.9))
                    .clipShape(Circle())
            }
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

            
        }
        .padding()
    }
    
}
