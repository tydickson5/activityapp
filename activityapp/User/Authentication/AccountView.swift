//
//  AccountView.swift
//  caravyn
//
//  Created by Ty Dickson on 6/17/26.
//

import SwiftUI

struct AccountView: View {
    
    @EnvironmentObject var authHandler: AuthHandler
    @EnvironmentObject var postHandler: PostsHandler
    
    @ObservedObject var pendingStore = PendingPostService.shared
    
    
    var body: some View {
        NavigationStack{
            VStack{
                Form{
                    Section{
                        NavigationLink {
                            AccountSettingsView()
                        } label: {
                            Label("Settings", systemImage: "cog.fill")
                        }
                    }
                    Section("Uploading posts"){
                        ForEach(pendingStore.pendingPosts){ result in
                            HStack{
                                if let image = pendingStore.previewImage(for: result) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                Spacer()
                                Button(action:{
                                    pendingStore.remove(result)
                                }){
                                    Image(systemName: "trash.fill")
                                        .foregroundStyle(Color.red)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.dark)
                                    .stroke(Color.dark.opacity(0.5), lineWidth: 2)
                            )
                            
                            
                        }
                    }
                    Section("My Posts"){
                        ForEach(postHandler.userPosts){ post in
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
                }

            }
            .padding()
            .refreshable(action: {
                await postHandler.getUsersPosts(userId: authHandler.user!.id)
            })
        }
    }
}
