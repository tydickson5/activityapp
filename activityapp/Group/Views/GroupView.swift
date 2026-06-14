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
    
    @State var groupName: String = ""
    

    @State private var isExpanded = false
    
    
    var body: some View {
        ScrollView{
            VStack{
                DisclosureGroup("Select Group", isExpanded: $isExpanded){
                    VStack{
                        ForEach(groupHandler.groups){ group in
                            HStack{
                                Text(group.name)
                                Spacer()
                                if(groupHandler.selectedGroup == group.id){
                                    Image(systemName: "checkmark").foregroundColor(Color.dark)
                                }
                            }
                            .padding()
                            .onTapGesture {
                                groupHandler.selectedGroup = group.id
                                Task{
                                    await groupHandler.updatedSelectedGroup(userId: authHandler.user!.id, groupId: group.id)
                                    authHandler.user?.selected_group = group.id
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.bottom,20)
                Text("-")
                Text("Create Group")
                
                TextField("Name", text: $groupName)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.dark.opacity(0.5), lineWidth: 2)
                    )
                Button(action:{
                    Task{
                        await groupHandler.createGroup(userId: authHandler.user!.id, name: groupName)
                    }
                    
                }){
                    Text("Create")
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                        .tint(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.lightBlue)
                        .stroke(Color.lightBlue.opacity(0.5), lineWidth: 2)
                )

                Button(action:{
                    Task{
                        authHandler.logout()
                    }
                }){
                    Text("Logout of Account")
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                        .tint(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.red)
                        .stroke(Color.red.opacity(0.5), lineWidth: 2)
                )
            }
            .padding()
        }
        .refreshable {
            await groupHandler.loadGroups(user: authHandler.user!)
        }
        
        
    }
        
    
}
