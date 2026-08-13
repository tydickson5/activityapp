//
//  ResetPasswordView.swift
//  caravyn
//
//  Created by Ty Dickson on 6/16/26.
//
import SwiftUI

struct ResetPasswordView: View {
    @EnvironmentObject var authHandler: AuthHandler
    @State private var newPassword = ""
    @State private var confirm = ""
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text("New Password")
                .font(.title)
            SecureField("New password", text: $newPassword)
                .textFieldStyle(.roundedBorder)
            SecureField("Confirm password", text: $confirm)
                .textFieldStyle(.roundedBorder)
            Button("Update Password") {
                guard newPassword == confirm else {
                    ToastManager.shared.error("Passwords don't match")
                    return
                }
                Task {
                    await authHandler.updatePassword(newPassword: newPassword)
                    isPresented = false
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
