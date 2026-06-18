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
    
    @EnvironmentObject var locationHandler: LocationHandler
    
    @State private var image: UIImage?
    @State private var showCamera = false
    
    @State private var video: URL?
    @State private var showVideo = false
    @State private var thumbnail: UIImage?
    
    @State private var caption: String = ""
    @State private var isImage: Bool = true
    
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
                    .onChange(of:video){ url in
                        guard let url else {
                            return
                        }
                        thumbnail = groupHandler.postHandler.generateThumbnail(from: url)
                        isImage = false
                    }
                    
                }
                
                        
                Button(action:{
                    Task{
                    
                        
                        guard groupHandler
                            .selectedGroup != nil
                        else {
                            return
                        }
                        
                        if isImage{
                            await groupHandler.postHandler.createImagePost(imageURL: image!, userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!, caption: caption, latitude: locationHandler.latitude, longitude: locationHandler.longitude)
                        } else {
                            print("vid")
                            await groupHandler.postHandler.createVideoPost(videoURL: video!, thumbnailURL: thumbnail!, userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!, caption: caption, latitude: locationHandler.latitude, longitude: locationHandler.longitude)
                        }
                        
                        
                        
                        
                        caption = ""
                        self.image = nil
                        
                        await groupHandler.postHandler.getPosts(userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!)
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
            }
            .padding()
            
            .sheet(
                isPresented:
                    $showCamera
            ) {

                CameraView(
                    image: $image
                )
            }
            .fullScreenCover(isPresented: $showVideo){
                
                VideoView(recordedVideoUrl: $video)
            }
            if(groupHandler.postHandler.isLoading){
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                ProgressView()
                    .scaleEffect(1.5)
            }
        }

        
                
        
            
        
    }
    
}
