//
//  Buttons.swift
//  caravyn
//
//  Created by Ty Dickson on 6/16/26.
//

import SwiftUI

struct ButtonsElement: View {
    
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var postStore: PostStore
    @EnvironmentObject var friendStore: FriendStore
    var locationManager: LocationHandler
    
    @Binding var publicPost: Bool
    
    var body: some View {
        VStack(spacing: 12){
            Button(action:{
                publicPost.toggle()
            }){
                HStack {
                    Text(publicPost ? "Friends" : "Public")
                    Image(systemName: publicPost ? "person.2.fill" : "eye")
                }
                .font(.caption)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.dark.opacity(0.9))
                .clipShape(Capsule())
                
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            Button(action:{
                Task{
                    guard let userId = authStore.user?.id else {
                        return
                    }
                    await postStore.loadPosts(userId: userId, friends: friendStore.friends)
                }
            }){
                Image(systemName: "arrow.clockwise")
                    .frame(width: 15, height: 15)
                    .foregroundStyle(Color.white)
                    .padding()
                    .background(Color.dark.opacity(0.9))
                    .clipShape(Circle())
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            Button(action:{
                locationManager.recenter()
            }){
                Image(systemName: "location")
                    .frame(width: 15, height: 15)
                    .foregroundStyle(Color.white)
                    .padding()
                    .background(Color.dark.opacity(0.9))
                    .clipShape(Circle())
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            Spacer()
            
        }
        .fixedSize()
        .padding(.top, 0)
        .padding(.trailing, 16)

    }
    
}
