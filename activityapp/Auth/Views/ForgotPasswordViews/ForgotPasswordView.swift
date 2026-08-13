//
//  ForgotPasswordView.swift
//  caravyn
//
//  Created by Ty Dickson on 6/16/26.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    private var authService: AuthService = AuthService()
    @Environment(\.dismiss) var dismiss
    @State private var email = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Reset Password")
                .font(.title)
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            Button("Send Reset Email") {
                Task {
                    do {
                        try await authService.sendPasswordReset(email: email)
                        dismiss()
                    } catch {
                        ToastManager.shared.error("Error")
                    }
                    
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
