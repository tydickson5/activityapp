//
//  PostView.swift
//  activityapp
//
//  Created by Ty Dickson on 5/31/26.
//
import SwiftUI

struct PostView: View{
    
    @EnvironmentObject var groupHandler: GroupsHandler
    @EnvironmentObject var authHandler: AuthHandler
    @EnvironmentObject var postHandler: PostsHandler
    
    @EnvironmentObject var locationHandler: LocationHandler
    
    @State private var image: UIImage?
    @State private var showCamera = false
    
    @State private var video: URL?
    @State private var showVideo = false
    @State private var thumbnail: UIImage?
    
    @State private var caption: String = ""
    @State private var isImage: Bool = true
    
    @State private var postToPublic: Bool = false
    @State private var showAlert: Bool = false
    
    var body: some View{
        
        ZStack{
            VStack{
                
                if let image {
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            height: 400
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                }
                if let thumbnail {
                    Text("Video Thumbnail")
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            height: 400
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 25))
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
                
                TextField("caption", text: $caption)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.dark.opacity(0.5), lineWidth: 2)
                    )
                HStack{
                    Button(action:{
                        
                        Task{
                            showCamera = true
                        }
                        isImage = true
                        video = nil
                    }){
                        Text("Take Picture")
                            .frame(maxWidth: .infinity)
                            .frame(height: 20)
                            .tint(.white)
                        
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.lightBlue)
                            .stroke(Color.lightBlue.opacity(0.5), lineWidth: 2)
                    )
                    Button(action:{
                        
                        Task{
                            showVideo = true
                        }
                        isImage = false
                        image = nil
                    }){
                        Text("Take Video")
                            .frame(maxWidth: .infinity)
                            .frame(height: 20)
                            .tint(.white)
                        
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.lightBlue)
                            .stroke(Color.lightBlue.opacity(0.5), lineWidth: 2)
                    )
                    
                    
                }
                
                        
                Button(action:{
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
                            if isImage{
                                await postHandler.createImagePost(imageURL: image!, userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!, caption: caption, latitude: locationHandler.latitude, longitude: locationHandler.longitude, isPublicPost: postToPublic)
                            } else {
                                print("vid")
                                await postHandler.createVideoPost(videoURL: video!, thumbnailURL: thumbnail!, userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!, caption: caption, latitude: locationHandler.latitude, longitude: locationHandler.longitude, isPublicPost: postToPublic)
                            }
                            
                            
                            
                            
                            caption = ""
                            self.image = nil
                            postToPublic = false
                            await postHandler.getPosts(userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!)
                        }
                        
                        
                    }
                    
                    
                }){
                    Text("Post")
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
                            if isImage{
                                await postHandler.createImagePost(imageURL: image!, userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!, caption: caption, latitude: locationHandler.latitude, longitude: locationHandler.longitude, isPublicPost: postToPublic)
                            } else {
                                print("vid")
                                await postHandler.createVideoPost(videoURL: video!, thumbnailURL: thumbnail!, userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!, caption: caption, latitude: locationHandler.latitude, longitude: locationHandler.longitude, isPublicPost: postToPublic)
                            }
                            
                            
                            
                            
                            caption = ""
                            self.image = nil
                            
                            await postHandler.getPosts(userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!)
                            postToPublic = false
                        }
                    }, secondaryButton: .cancel())
                }
            }
            .padding()
            .onChange(of:video){ url in
                guard let url else {
                    return
                }
                thumbnail = postHandler.generateThumbnail(from: url)
                isImage = false
            }
            .sheet(
                isPresented:
                    $showCamera
            ) {

                CameraView(
                    image: $image
                )
            }
            .fullScreenCover(isPresented: $showVideo){
                
                VideoView(recordedVideoUrl: $video){
                    showVideo = false
                }
            }
            if(postHandler.isLoading){
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                ProgressView()
                    .scaleEffect(1.5)
            }
            
        }

        
                
        
            
        
    }
    
}
