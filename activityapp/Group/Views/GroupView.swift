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
    
    @State var groupid: String = "70f2584b-8e91-4e3c-bf13-f915c098876b"
    
    
    var body: some View {
        VStack{
            Text("groups")
            ForEach(groupHandler.groups) { group in
                Text(group.name)
            }
            
            TextField("name", text: $groupName)
            Button(action:{
                Task{
                    await groupHandler.createGroup(userId: authHandler.user!.id, name: groupName)
                }
                
            }){
                Text("Create")
            }
            Button(action:{
                Task{
                    await groupHandler.joinGroup(userId: authHandler.user!.id, groupId: groupid)
                }
            }){
                Text("Join")
            }
            Button(action:{
                Task{
                    authHandler.logout()
                }
            }){
                Text("Logout")
            }
        }
        
    }
    
}
