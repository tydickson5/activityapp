//
//  PostPreviewElement.swift
//  caravyn
//
//  Created by Ty Dickson on 8/3/26.
//

import SwiftUI
import AVFoundation
import _AVKit_SwiftUI

struct PostPreviewElement: View {
    
    let media: CameraResult
    @EnvironmentObject var postStore: PostStore
    var uploadPostService = UploadPostService()
    
    let userId: String
    let groupId: String
    let latitude: Double
    let longitude: Double
    
    
    var onPosted: () -> Void
    
    @State private var caption: String = ""
    @State private var isSubmitting = false
    
    @State var isPublicPost = false
    @State var saveToLibrary = true
    
    var body: some View {
        VStack{
            
            mediaPreview
                .frame(maxWidth: .infinity, maxHeight: 450)
                .clipped()
                .padding(.bottom, 10)
            
            
            
            Toggle(isOn: $saveToLibrary) {
                Text("Save to your photo library?")
            }
            .tint(.lightBlue)
            
            HStack{
                Text("Post to: ")
                Spacer()
                Button(action: {
                    isPublicPost = false
                }){
                    Text("Friends")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(isPublicPost ? Color.lightGray : Color.lightBlue, in: Capsule())
                        .foregroundColor(.black)
                }
                Button(action: {
                    isPublicPost = true
                }){
                    Text("Public")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(isPublicPost ? Color.lightBlue : Color.lightGray, in: Capsule())
                        .foregroundColor(.black)
                }
            }
            
            TextField("Write a caption...", text: $caption)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.dark.opacity(0.5), lineWidth: 2)
                )
            
            Button(action:{
                submit(saveToLibrary: saveToLibrary)
            }) {
                if isSubmitting {
                    ProgressView()
                } else {
                    Text("Post").frame(maxWidth: .infinity)
                        .frame(height: 20)
                        .tint(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.dark)
                    .stroke(Color.dark.opacity(0.5), lineWidth: 2)
            )
            .disabled(isSubmitting)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var mediaPreview: some View {
        switch media {
        case .photo(let image):
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        case .video(let url):
            VideoPlayer(player: AVPlayer(url: url))
        }
    }
    
    private func submit(saveToLibrary: Bool) {
        isSubmitting = true
        
        switch media {
        case .photo(let image):
            if saveToLibrary{PhotoLibrarySaver.save(image: image)}
            _ = PendingPostService.shared.enqueueImage(
                image: image, caption: caption, userId: userId, groupId: groupId,
                latitude: latitude, longitude: longitude, isPublicPost: isPublicPost
            )
        case .video(let url):
            if saveToLibrary{PhotoLibrarySaver.save(videoURL: url)}
            if let thumbnail = uploadPostService.generateThumbnail(from: url) {
                _ = PendingPostService.shared.enqueueVideo(
                    videoURL: url, thumbnail: thumbnail, caption: caption, userId: userId,
                    groupId: groupId, latitude: latitude, longitude: longitude, isPublicPost: isPublicPost
                )
            }
        }
        
        // Attempt immediately (covers the common "online" case fast);
        // if it's offline, PostUploadQueue's NWPathMonitor will pick it
        // up automatically the moment connectivity returns.
        postStore.runInBackground {
            PostUploadQueue.shared.retryAll()
        }
        
        onPosted()
    }
}
