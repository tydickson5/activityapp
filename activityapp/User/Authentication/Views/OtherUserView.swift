//
//  OtherUserView.swift
//  caravyn
//
//  Created by Ty Dickson on 8/6/26.
//

import SwiftUI

struct OtherUserView: View {
    
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var friendStore: FriendStore
    @EnvironmentObject var postStore: PostStore
    var retrievePostService = RetrievePostService()
    var friendService = FriendService()
    var friendRequestService = FriendRequestService()
    
    var dateFormatterService = DateFormatterService()
    
    @State var userPosts: [Post] = []
    
    @State var user: AppUser
    
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
                if(user.id == authStore.user?.id){
                    Text("Your profile")
                }
                else if(friendService.isFriend(friendId: user.id, friends: friendStore.friends)){
                    Text("You are friends!")
                        .padding(.bottom, 10)
                } else if(friendRequestService.friendRequestSent(friendId: user.id, sentFriendRequests: friendStore.sentFriendRequests)) {
                    Text("Request sent!")
                        .padding(.bottom, 10)
                } else if(friendRequestService.friendRequestRecieved(friendId: user.id, recievedFriendRequests: friendStore.recievedFriendRequests)){
                    Text("Check you inbox!")
                        .padding(.bottom, 10)
                } else {
                    Button{
                        Task{
                            guard let u = authStore.user else {return}
                            await friendStore.sendFriendRequest(userId: u.id, friendId: user.id, friendUsername: u.username)

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
                            if let image = retrievePostService.imageURL(path: post.media_url!) {
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
                                    Text(dateFormatterService.formattedDate(post.created_at))
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
            Task {
                let userId = user.id
                userPosts = await retrievePostService.getUsersPosts(userId: userId)
            }
            
        }
        .onAppear{
            //load posts
            Task{
                let userId = user.id
                userPosts = await retrievePostService.getUsersPosts(userId: userId)
            }
            
            
        }
    }
}
