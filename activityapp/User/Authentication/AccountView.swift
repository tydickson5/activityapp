//
//  AccountView.swift
//  caravyn
//
//  Created by Ty Dickson on 6/17/26.
//

import SwiftUI

struct AccountView: View {
    
    @EnvironmentObject var authHandler: AuthHandler
    
    var body: some View {

        AccountPostListElement()
    }
        
        
    
}
