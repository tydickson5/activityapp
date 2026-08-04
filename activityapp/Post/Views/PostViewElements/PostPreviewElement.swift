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
    @StateObject var postHandler = PostsHandler()
    
    let userId: String
    let groupId: String
    let latitude: Double
    let longitude: Double
    let isPublicPost: Bool
    
    var onPosted: () -> Void
    
    @State private var caption: String = ""
    @State private var isSubmitting = false
    
    var body: some View {
        VStack{
            mediaPreview
                .frame(maxWidth: .infinity, maxHeight: 400)
                .clipped()
            
            TextField("Write a caption...", text: $caption, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            Button {
                submit()
            } label: {
                if isSubmitting {
                    ProgressView()
                } else {
                    Text("Post").frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .disabled(isSubmitting)
            
            Spacer()
        }
        .padding()
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
    
    private func submit() {
        isSubmitting = true
        
        switch media {
        case .photo(let image):
            PhotoLibrarySaver.save(image: image)
            _ = PendingPostService.shared.enqueueImage(
                image: image, caption: caption, userId: userId, groupId: groupId,
                latitude: latitude, longitude: longitude, isPublicPost: isPublicPost
            )
        case .video(let url):
            PhotoLibrarySaver.save(videoURL: url)
            if let thumbnail = postHandler.generateThumbnail(from: url) {
                _ = PendingPostService.shared.enqueueVideo(
                    videoURL: url, thumbnail: thumbnail, caption: caption, userId: userId,
                    groupId: groupId, latitude: latitude, longitude: longitude, isPublicPost: isPublicPost
                )
            }
        }
        
        // Attempt immediately (covers the common "online" case fast);
        // if it's offline, PostUploadQueue's NWPathMonitor will pick it
        // up automatically the moment connectivity returns.
        postHandler.runInBackground {
            PostUploadQueue.shared.retryAll()
        }
        
        onPosted()
    }
}
