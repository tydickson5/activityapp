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
    
    func formattedDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: isoString) else {
            return isoString
        }

        let output = DateFormatter()
        output.dateStyle = .medium
        output.timeStyle = .short

        return output.string(from: date)
    }
    
    var body: some View {
        ScrollView{
            VStack{
                //profile info
                HStack{
                    Text(user.username)
                        .font(.title)
                    Spacer()
                }
                .padding(.bottom, 20)
                
                
                //friend request
                //check if friend/request exists already
                if(user.id == authHandler.user!.id){
                    Text("Your profile")
                }
                else if(friendHandler.userIsFriend(friendId: user.id)){
                    Text("You are friends!")
                        .padding(.bottom, 10)
                } else if(friendHandler.requestSent(userId: authHandler.user!.id)) {
                    Text("Request sent!")
                        .padding(.bottom, 10)
                } else if(friendHandler.requestRecieved(friendId: user.id)){
                    Text("Check you inbox!")
                        .padding(.bottom, 10)
                } else {
                    Button{
                        Task{
                            await friendHandler.sendFriendRequest(userId: authHandler.user!.id, friendId: user.id, friendUsername: authHandler.user!.username)
                        }
                        
                    } label: {
                        Label("Send friend request", systemImage: "person.badge.plus")
                            .foregroundStyle(Color.lightBlue)
                            .padding(.bottom, 30)
                    }
                }
                
                
                //posts
                ForEach(userPosts){ post in
                    NavigationLink(destination: PostDetailView(post: post), label: {
                        
                        HStack{
                            if let image = postHandler.imageURL(path: post.media_url!) {
                                AsyncImage(url: image) { phase in
                                    switch phase {
                                    case .success(let img):
                                        img
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .foregroundStyle(.gray)
                                    default:
                                        ProgressView()
                                    }
                                }
                                .frame(width: 130, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            Spacer()
                            VStack{
                                Text(post.caption)
                                    .font(.footnote)
                                    .multilineTextAlignment(.leading)

                                Spacer()
                                HStack{
                                    Text(formattedDate(post.created_at))
                                        .font(.footnote)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .imageScale(.large)
                                }
                                
                            }
                            
                        }
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        
                    })
                    .padding(.bottom, 10)
                    
                }
            }
            .padding()

        }
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
