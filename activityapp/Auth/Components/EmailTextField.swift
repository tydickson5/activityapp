//
//  EmailTextField.swift
//  caravyn
//
//  Created by Ty Dickson on 8/13/26.
//

import SwiftUI

struct EmailTextField: View {
    
    @Binding var email: String
    
    var body: some View {
        TextField("Email", text: $email)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.dark.opacity(0.5), lineWidth: 2)
            )
            .keyboardType(.emailAddress)
    }
}

