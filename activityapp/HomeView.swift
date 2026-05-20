//
//  HomeView.swift
//  activityapp
//
//  Created by Ty Dickson on 5/13/26.
//

import SwiftUI

struct HomeView: View{
    
    
    @EnvironmentObject var authHandler: AuthHandler
    
    var body: some View {
        
        
        Text(authHandler.user?.username ?? "")
        
    }
}

