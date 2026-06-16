//
//  HomeView.swift
//  activityapp
//
//  Created by Ty Dickson on 5/13/26.
//

import SwiftUI
import MapKit

struct HomeView: View {
    
    @EnvironmentObject var groupHandler: GroupsHandler
    @EnvironmentObject var authHandler: AuthHandler
    @ObservedObject var postHandler: PostsHandler
        
    init(postHandler: PostsHandler) {
        self.postHandler = postHandler
    }
    
    
    
    var body: some View {
        NavigationStack {
            ZStack{
                MapElement(postHandler: self.postHandler)
                
            }
            
        }
    }
}
