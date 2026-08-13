//
//  PasswordSecureField.swift
//  caravyn
//
//  Created by Ty Dickson on 8/13/26.
//

import SwiftUI

struct PasswordSecureField: View {
    
    @Binding var password: String
    var typeNormal: Bool
    
    var body: some View {
        SecureField(typeNormal ? "Password" : "Confirm Password", text: $password)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.dark.opacity(0.5), lineWidth: 2)
            )
        
    }
}
