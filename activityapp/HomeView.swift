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
    @EnvironmentObject var postHandler: PostsHandler
    @EnvironmentObject var friendHandler: FriendHandler

    
    var body: some View {
        NavigationStack {
            ZStack{
                MapElement()
            }
        }
    }
}
