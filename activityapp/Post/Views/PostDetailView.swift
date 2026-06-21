//
//  PostDetailView.swift
//  activityapp
//
//  Created by Ty Dickson on 6/1/26.
//
import SwiftUI
import AVFoundation
import _AVKit_SwiftUI

struct PostDetailView: View {
    
    let post: Post
    
    @EnvironmentObject var groupHandler: GroupsHandler
    @EnvironmentObject var postHandler: PostsHandler
    
    @State private var player: AVPlayer?
    
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
        VStack{
            if(post.media_type == "image"){
                AsyncImage(
                    url: postHandler
                        .imageURL(
                            path: post.media_url!
                        )
                ) { image in

                    image
                        .resizable()
                        .scaledToFill()

                        .frame(maxWidth: .infinity)
         
                        
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 12
                            )
                        )

                } placeholder: {

                    ProgressView()
                        
                }
            } else {
                if let player {
                    VideoPlayer(player: player)
                        .frame(maxWidth: .infinity)
                } else {
                    if let thumbPath = post.media_url,
                       let thumbURL = postHandler.imageURL(path: thumbPath) {
                        AsyncImage(url: thumbURL) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 300)
                    }
                    
                }
                
            }
        }
        .task {
            guard post.media_type == "video" else { return }
            
            if let videoPath = await postHandler.getVideoUpload(postId: post.id),
               let videoURL = postHandler.imageURL(path: videoPath) {
                player = AVPlayer(url: videoURL)
                player?.play()
            }
        }
        
        
        
        Text(post.caption)
        Text(formattedDate(post.created_at))

    }
}
