//
//  VideoView.swift
//  caravyn
//
//  Created by Ty Dickson on 6/22/26.
//

import SwiftUI

struct VidView: View {
    
    @EnvironmentObject var groupHandler: GroupsHandler
    @EnvironmentObject var authHandler: AuthHandler
    @EnvironmentObject var postHandler: PostsHandler
    @EnvironmentObject var locationHandler: LocationHandler
    @EnvironmentObject var friendHandler: FriendHandler
    
    @State private var video: URL?
    @State private var thumbnail: UIImage?
    @State private var showVideo = false
    
    @State private var openOnView: Bool?
    
    @State private var caption: String = ""
    
    @State private var postToPublic: Bool = false
    @State private var showAlert: Bool = false
    
    func makePost() async{
        guard (video != nil) else {
            ToastManager.shared.error("No video")
            return
        }
        
        //await postHandler.createVideoPost(videoURL: video!, thumbnailURL: thumbnail!, userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!, caption: caption, latitude: locationHandler.latitude, longitude: locationHandler.longitude, isPublicPost: postToPublic)
    }
    
    var body: some View {
        
        VStack{
            
            //preview thumbnail
            if let thumbnail {
                ImagePreviewElement(image: thumbnail)
            }
            
            Spacer()
            
            if(groupHandler.selectedGroup != "6ce9c8f8-2ff2-4f12-8f74-19671fcfb265"){
                HStack{
                    Text("Post to public")
                    Spacer()
                    Toggle("", isOn: $postToPublic)
                        .labelsHidden()
                        .onTapGesture {
                            print("clicked")
                        }
                }
            }
            
            //caption
            HStack{
                TextField("caption", text: $caption)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.lightBlue.opacity(0.5), lineWidth: 2)
                    )
                Button(action: {
                    Task{
                        showVideo = true
                    }
                }){
                    Image(systemName: "camera")
                        .foregroundStyle(Color.lightBlue)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.lightBlue.opacity(0.5), lineWidth: 2)
                )
            }
            
            //submit button
            Button(action: {
                Task{
                    guard groupHandler
                        .selectedGroup != nil
                    else {
                        return
                    }
                    
                    if(groupHandler.selectedGroup == "6ce9c8f8-2ff2-4f12-8f74-19671fcfb265"){
                        postToPublic = true
                    }
                    
                    if(postToPublic){
                        showAlert.toggle()
                    } else {
                        await makePost()
                        caption = ""
                        self.video = nil
                        postToPublic = false
                        await postHandler.getPosts(userId: authHandler.user!.id, friends: friendHandler.friends)
                    }
                    
                    
                }
            }){
                Text(postHandler.isLoading ? "Loading..." :"Post")
                    .frame(maxWidth: .infinity)
                    .frame(height: 20)
                    .tint(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.dark)
                    .stroke(Color.dark.opacity(0.5), lineWidth: 2)
            )
            .alert(isPresented: $showAlert){
                Alert(title: Text("Post to public"), message: Text("Are you sure you want to post to the public group everyone can see?"), primaryButton: .destructive(Text("Yes").foregroundStyle(Color.lightBlue)){
                    Task{
                        await makePost()
                        caption = ""
                        self.video = nil
                        postToPublic = false
                        await postHandler.getPosts(userId: authHandler.user!.id, friends: friendHandler.friends)
                    }
                }, secondaryButton: .cancel())
            }
            
        }
        .onChange(of:video){ url in
            guard let url else {
                return
            }
            thumbnail = postHandler.generateThumbnail(from: url)
        }
        .fullScreenCover(isPresented: $showVideo){
            
            VideoView(recordedVideoUrl: $video){
                showVideo = false
            }
        }

    }
}
