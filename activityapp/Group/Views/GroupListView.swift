//
//  GroupListView.swift
//  caravyn
//
//  Created by Ty Dickson on 6/20/26.
//

import SwiftUI

struct GroupListView: View {
    
    @EnvironmentObject var groupHandler: GroupsHandler
    
    var body: some View{
        NavigationStack {
            Form{
                ForEach(groupHandler.groups){ group in
                    Section(){
                        HStack{
                            Text(group.name)
                            Spacer()
                            NavigationLink("", destination: GroupDetailView(group: group))
                            
                        }
                    }
                    
                }
                

            }
            
            

            
        }
    }
}
