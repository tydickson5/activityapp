//
//  MediaElement.swift
//  caravyn
//
//  Created by Ty Dickson on 8/20/26.
//

import SwiftUI
import AVFoundation
import NukeUI
import _AVKit_SwiftUI

struct MediaElement: View {
    
    @Binding var post: Post
    
    @EnvironmentObject var postStore: PostStore
    var retrievePostService = RetrievePostService()
    
    @State private var player: AVPlayer?
    
    var body: some View {
        HStack {
            if(post.media_type == "image") {
                LazyImage(url: retrievePostService.imageURL(path: post.media_url!)) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 12
                                )
                            )
                    } else {
                        ProgressView()
                    }
                }
            } else {
                if let player {
                    VideoPlayer(player: player)
                        .frame(maxWidth: .infinity)
                        .frame(height: 400)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12)
                            )
                } else {
                    if let thumbnailPath = post.media_url, let thumbnailURL = retrievePostService.imageURL(path: thumbnailPath) {
                        LazyImage(url: thumbnailURL) { state in
                            if let image = state.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius: 12
                                        )
                                    )
                            } else {
                                ProgressView()
                            }
                        }
                    }
                }
                
            }
        }
        .task(id: post.id){
            guard post.media_type == "video" else { return }
            
            if let videoPath = await retrievePostService.getVideoUpload(postId: post.id),
               let videoURL = retrievePostService.imageURL(path: videoPath) {
                print("Video URL: \(videoURL)")
                player = AVPlayer(url: videoURL)

                Task {
                    for _ in 0..<10 {
                        try? await Task.sleep(for: .seconds(1))

                        guard let item = player?.currentItem else {
                            print("No current item")
                            continue
                        }

                        print("Status:", item.status.rawValue)

                        if let error = item.error {
                            print("Item error:", error)
                        }

                        if item.status == .readyToPlay {
                            print("READY")
                            break
                        }

                        if item.status == .failed {
                            print("FAILED")
                            break
                        }
                    }
                }
                player?.play()
            } else {
                print("Failed to get video path or URL for post \(post.id)")
            }
        }
        .onDisappear {
            player?.pause()
            player?.replaceCurrentItem(with: nil)
            player = nil
        }
    }
}
