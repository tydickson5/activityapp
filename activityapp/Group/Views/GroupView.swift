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
    @EnvironmentObject var friendHandler: FriendHandler
    
    @State var showGroups: Bool = false
    @State var newGroupName: String = ""

    @State private var isExpanded = false
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section(){
                    HStack{
                        NavigationLink(
                            "My Groups", destination: GroupListView())
                    
                    }
                }
                Section("Create Group") {
                    HStack{
                        TextField("Group Name", text: $newGroupName)
                            .padding(5)

                        Spacer()
                        Button(action:{
                            
                            Task{
                                
                                
                                if let groupId = await groupHandler.createGroup(userId: authHandler.user!.id, name: newGroupName) {
                                    print(groupId)
                                    authHandler.user?.selected_group = groupId
                                    newGroupName = ""
                                    await postHandler.getPosts(userId: authHandler.user!.id, friends: friendHandler.friends)
                                }
                            }
                        }){
                            Text(groupHandler.creatingGroup ? "Loading..." :"Create")
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
