//
//  GroupDetailView.swift
//  caravyn
//
//  Created by Ty Dickson on 6/20/26.
//
import SwiftUI

struct GroupDetailView: View {
    
    var group: Group
    @State private var members: [AppUser] = []
    
    @EnvironmentObject var groupHandler: GroupsHandler
    @EnvironmentObject var authHandler: AuthHandler
    @EnvironmentObject var postHandler: PostsHandler
    @EnvironmentObject var friendHandler: FriendHandler
    
    var body: some View{
        NavigationStack {
            Form{
                Section(group.name){
                    if(group.id == groupHandler.selectedGroup){
                        HStack{
                            Text("This group is selected")
                        }
                    } else {
                        HStack{
                            Text("Select Group")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .onTapGesture {
                            print("selected")
                            groupHandler.selectedGroup = group.id
                            Task{
                                await groupHandler.updatedSelectedGroup(userId: authHandler.user!.id, groupId: group.id)
                                authHandler.user?.selected_group = group.id
                                await postHandler.getPosts(userId: authHandler.user!.id, friends: friendHandler.friends)
                            }
                        }
                    }
                    ShareLink(
                        item: "Join \(group.name) https://caravyn.com/group/\(group.id)"
                    ) {
                        Label("Share group", systemImage: "square.and.arrow.up")
                            .foregroundStyle(Color.lightBlue)
                    }
                    .tint(Color.lightBlue)
                }

                Section("Members"){
                    ForEach(members, id: \.id) { member in
                                        HStack {
                                            Text(member.username)
                                        }
                                    }
                }
            }
            .task {
                members = await groupHandler.getGroupMembers(group: group)
                print(members)
            }
    
        }
    }
}

