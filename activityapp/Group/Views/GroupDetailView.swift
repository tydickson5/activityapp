//
//  GroupDetailView.swift
//  caravyn
//
//  Created by Ty Dickson on 6/20/26.
//
import SwiftUI

struct GroupDetailView: View {
    
    var group: Group
    
    var body: some View{
        NavigationStack {
            Text(group.name)
        }
    }
}

