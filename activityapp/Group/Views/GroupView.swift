//
//  GroupView.swift
//  activityapp
//
//  Created by Ty Dickson on 5/23/26.
//
import SwiftUI

struct GroupView: View{
    
    @EnvironmentObject var groupHandler: GroupsHandler
    @EnvironmentObject var authHandler: AuthHandler
    @EnvironmentObject var postHandler: PostsHandler
    
    @State var showGroups: Bool = false
    @State var newGroupName: String = ""

    @State private var isExpanded = false
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Select Group"){
                    HStack{
                        NavigationLink(
                            "go", destination: GroupListView())
                    
                    }
                    HStack{
                        Text("Select")
                        Spacer()
                        Image(systemName: showGroups ? "chevron.down": "chevron.right")
                            
                    }
                    .onTapGesture {
                        showGroups.toggle()
                    }
                    ForEach(groupHandler.groups){ group in
                        if(group.id == groupHandler.selectedGroup || showGroups){
                            HStack{
                                if(groupHandler.selectedGroup == group.id){
                                    Image(systemName: "checkmark").foregroundColor(Color.lightBlue)
                                }
                                Text(group.name)
                                Spacer()
                                
                            }
                            .onTapGesture {
                                groupHandler.selectedGroup = group.id
                                Task{
                                    await groupHandler.updatedSelectedGroup(userId: authHandler.user!.id, groupId: group.id)
                                    authHandler.user?.selected_group = group.id
                                    await postHandler.getPosts(userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!)
                                }
                            }
                        }
                        
                    }
                    HStack {
                        ShareLink(
                            item: URL(string: "https://caravyn.com/group/\(groupHandler.selectedGroup ?? "notfound")")!
                        ) {
                            Label("Share selected group", systemImage: "square.and.arrow.up")
                                .foregroundStyle(Color.lightBlue)
                        }
                        .tint(Color.lightBlue)
                    }
                }
                Section("Create Group") {
                    HStack{
                        TextField("Group Name", text: $newGroupName)
                            .padding(5)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                            )
                        Spacer()
                        Button(action:{
                            
                            Task{
                                
                                
                                if let groupId = await groupHandler.createGroup(userId: authHandler.user!.id, name: newGroupName) {
                                    print(groupId)
                                    authHandler.user?.selected_group = groupId
                                    newGroupName = ""
                                    await postHandler.getPosts(userId: authHandler.user!.id, groupId: groupId)
                                }
                            }
                        }){
                            Text("Create")
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
            }
        }
        
        
        
    }
        
    
}
