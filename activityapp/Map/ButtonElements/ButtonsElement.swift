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
            Menu{
                ForEach(groupHandler.groups){ group in
                    Button {
                        groupHandler.selectedGroup = group.id
                        Task{
                            await groupHandler.updatedSelectedGroup(userId: authHandler.user!.id, groupId: group.id)
                            authHandler.user?.selected_group = group.id
                            await postHandler.getPosts(userId: authHandler.user!.id, groupId: group.id)
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
                HStack(spacing: 4) {  // wrap in HStack
                    Text(groupHandler.fetchGroupName(groupId: groupHandler.selectedGroup ?? "") ?? "Loading...")
                        .foregroundStyle(Color.white)
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.dark.opacity(0.9))
                .clipShape(Capsule())
            }
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
