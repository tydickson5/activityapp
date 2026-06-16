//
//  ForgotPasswordView.swift
//  caravyn
//
//  Created by Ty Dickson on 6/16/26.
//

import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authHandler: AuthHandler
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
                    await authHandler.sendPasswordReset(email: email)
                    dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
