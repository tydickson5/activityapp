//
//  PasswordCheck.swift
//  activityapp
//
//  Created by Ty Dickson on 5/14/26.
//0E232E
//55ADB3
//3A525F
//3A5D81
//1F1B26

import SwiftUI

struct PasswordCheck: View {
    
    
    
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var valid: Bool
    
    @State var eightChars: Bool = false
    @State var specialChars: Bool = false
    @State var numbers: Bool = false
    @State var capitalChars: Bool = false
    @State var match: Bool = false
    
    func hasCapitalChars(){
        if password.range(
            of: "[A-Z]",
            options: .regularExpression
        ) == nil {
            self.capitalChars = false
            return
        }
        self.capitalChars = true
    }
    
    func hasSpecialChars(){
        if password.range(
            of: "[^\\w\\s]",
            options: .regularExpression
        ) == nil {
            self.specialChars = false
            return
        }
        self.specialChars = true
    }
    
    func hasNumbers(){
        if password.range(
            of: "\\d",
            options: .regularExpression
        ) == nil {
            self.numbers = false
            return
        }
        self.numbers = true
    }
    
    func hasEightChars(){
        if password.count < 8 {
            self.eightChars = false
            return
        }
        self.eightChars = true
    }
    
    func doesMatch(){
        if(self.password != self.confirmPassword && self.password != ""){
            self.match = false
            return
        }
        self.match = true
    }
    
    func checkPasswords(){
        hasCapitalChars()
        hasNumbers()
        hasSpecialChars()
        hasEightChars()
        doesMatch()
        if(eightChars && specialChars && numbers && capitalChars && match){
            valid = true
        }
        else {
            valid = false
        }
    }
    
    
    var body: some View {
        SecureField("Password", text: $password)
            .onChange(of: password, {
                checkPasswords()
            })
            .textContentType(.oneTimeCode)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.dark.opacity(0.5), lineWidth: 2)
            )
        VStack{
            HStack{
                if(eightChars){
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.lightBlue)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                }
                
                Text("8+ characters")
                Spacer()
            }
            
            HStack{
                if(specialChars){
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.lightBlue)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                }
                Text("Special Character")
                Spacer()
            }
            HStack{
                if(numbers){
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.lightBlue)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                }
                Text("Number")
                Spacer()
            }
            HStack{
                if(capitalChars){
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.lightBlue)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                }
                Text("Capital letter")
                Spacer()
            }
        }
        .padding()
        
        
        
        SecureField("Confirm Password", text: $confirmPassword)
            .onChange(of: confirmPassword, {
                checkPasswords()
            })
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.dark.opacity(0.5), lineWidth: 2)
            )
        HStack{
            if(match){
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.lightBlue)
            } else {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.gray)
            }
            Text("Passwords match")
            Spacer()
        }
        .padding()
        
    }
}

