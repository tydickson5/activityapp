//
//  GroupPillSelectorElement.swift
//  caravyn
//
//  Created by Ty Dickson on 6/29/26.
//
import SwiftUI

struct GroupPillSelectorElement: View {
    
    @EnvironmentObject var groupHandler: GroupsHandler
    @EnvironmentObject var authHandler: AuthHandler
    @EnvironmentObject var postHandler: PostsHandler
    
    var body: some View{
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
    }
}
