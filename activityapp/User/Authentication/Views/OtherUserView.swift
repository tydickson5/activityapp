//
//  OtherUserView.swift
//  caravyn
//
//  Created by Ty Dickson on 8/6/26.
//

import SwiftUI

struct OtherUserView: View {
    
    @EnvironmentObject var authHandler: AuthHandler
    @EnvironmentObject var friendHandler: FriendHandler
    @EnvironmentObject var postHandler: PostsHandler
    
    @State var userPosts: [Post] = []
    
    @State var user: AppUser
    
    var body: some View {
        VStack{
            //profile info
            Text(user.username)
            
            //friend request
            Button{
                Task{
                    await friendHandler.sendFriendRequest(userId: authHandler.user!.id, friendId: user.id, friendUsername: user.username)
                }
                
            } label: {
                Label("Send friend request", systemImage: "person.badge.plus")
                    .foregroundStyle(Color.lightBlue)
            }
            
            //posts
            ForEach(userPosts){ post in
                NavigationLink(destination: PostDetailView(post: post), label: {
                    
                    HStack{
                        if let image = postHandler.imageURL(path: post.media_url!) {
                            AsyncImage(url: image)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    
                })
                
            }
        }
        .padding()
        .refreshable {
            //reload posts
            userPosts = await postHandler.getOtherUsersPosts(userId: user.id)!
        }
        .onAppear{
            //load posts
            Task{
                userPosts = await postHandler.getOtherUsersPosts(userId: user.id)!
            }
            
            
        }
    }
}
