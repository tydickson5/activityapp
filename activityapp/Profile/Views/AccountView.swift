//
//  AccountView.swift
//  caravyn
//
//  Created by Ty Dickson on 6/17/26.
//

import SwiftUI

struct AccountView: View {
    
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var postStore: PostStore
    var retrievePostService = RetrievePostService()
    
    @ObservedObject var pendingStore = PendingPostService.shared
    
    
    var body: some View {
        NavigationStack{
            Form{
                Section{
                    NavigationLink {
                        AccountSettingsView()
                    } label: {
                        Label("Settings", systemImage: "gear.fill")
                    }
                }
                Section {
                    StartTripButton()
                    NavigationLink {
                        TripsView()
                    } label: {
                        Label("Trips", systemImage: "plane.path.dotted")
                    }
                }
                if(!pendingStore.pendingPosts.isEmpty){
                    Section("Uploading posts"){
                        ForEach(pendingStore.pendingPosts){ result in
                            HStack{
                                if let image = pendingStore.previewImage(for: result) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 65, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    // fallback placeholder, e.g.:
                                    Image(systemName: "photo")
                                        .foregroundStyle(.secondary)
                                        .frame(width: 65, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                Spacer()
                                Button(action:{
                                    pendingStore.remove(result)
                                }){
                                    Image(systemName: "trash.fill")
                                        .foregroundStyle(Color.red)
                                }
                                .buttonStyle(.borderless)
                            }
                            
                            
                        }
                    }
                }
                
                Section("My Posts"){
                    ForEach(postStore.userPosts){ post in
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
                                    .frame(width: 65, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                Spacer()
                                if(post.latitude == 0){
                                    Text(post.id)
                                }
                                
                            }
                            
                        })
                        
                    }
                }
            }

        }
        .refreshable(action: {
            if let userId = authStore.user?.id{
                await postStore.loadUserPosts(userId: userId)
            } else {
                return
            }
        })
        .onAppear{
            Task{
                if let userId = authStore.user?.id{
                    await postStore.loadUserPosts(userId: userId)
                } else {
                    return
                }
            }
            
        }
    }
    
}
