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
    
    var post: Post
    @State var liked = false
    
    @State var user: AppUser? = nil
    
    @State var username = "Loading..."
    
    @State var newComment: String = ""
    @State var comments: [Comment] = []
    var commentHandler = CommentHandler()
    @State var commentLoading = false
    
    @EnvironmentObject var groupHandler: GroupsHandler
    @EnvironmentObject var postHandler: PostsHandler
    @EnvironmentObject var authHandler: AuthHandler
    var likeHander = LikesHandler()
    
    @State private var presentDeleteAlert: Bool = false
    
    
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
        ScrollView{
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
                            .frame(height: 500)
                    } else {
                        if let thumbPath = post.media_url,
                           let thumbURL = postHandler.imageURL(path: thumbPath) {
                            AsyncImage(url: thumbURL) { image in
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
                        }
                        
                    }
                    
                }
                Text(post.caption)
                    .padding(.bottom, 20)
                
                
                HStack{
                    if let user {
                        NavigationLink {
                            OtherUserView(user: user)
                        } label: {
                            HStack {
                                Text(user.username)
                                Image(systemName: "chevron.right")
                            }
                        }
                    } else {
                        HStack {
                            Text("Loading...")
                            Image(systemName: "chevron.right")
                        }
                    }
                    Spacer()
                }
                .padding(.bottom, 10)
                
                
                //like
                HStack{
                    HStack{
                        Text(formattedDate(post.created_at))
                        Spacer()
                        if(liked){
                            Button(action:{
                                Task{
                                    await likeHander.unlikePost(postId: post.id, userId: authHandler.user!.id,likes: post.post_likes-1)
                                    postHandler.updatePostLikeCount(postId: post.id, likes: post.post_likes - 1)
                                }
                                self.liked = false
                            }){
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(Color.red)
                            }
                        } else{
                            Button(action: {
                                Task{
                                    await likeHander.likePost(postId: post.id, likes: post.post_likes+1, userId: authHandler.user!.id)
                                    postHandler.updatePostLikeCount(postId: post.id, likes: post.post_likes + 1)
                                }
                                self.liked = true
                                //post.post_likes = post.post_likes + 1
                            }){
                                Image(systemName: "heart")
                                    .foregroundStyle(Color.gray)
                            }
                        }
                        Text("\(post.post_likes) Likes")
                    }
                    
                }
                
                //comment text field
                HStack{
                    TextField("Add a comment", text: $newComment)
                    Button(action:{
                        Task{
                            commentLoading = true
                            comments = await commentHandler.addComment(userId: authHandler.user!.id, postId: post.id, comment: newComment, comments: comments)
                            newComment = ""
                            commentLoading = false
                        }
                        
                    }){
                        Text(commentLoading ? "Sending..." :"Send")
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.dark.opacity(0.5), lineWidth: 2)
                )
                .padding(.bottom, 10)
                .padding(.top, 10)
                
                //comments
                VStack{
                    ForEach(comments, id: \.id) { (comment: Comment) in
                        
                        HStack{
                            Text(comment.comment)
                            Spacer()
                            if(comment.user_id == authHandler.user!.id){
                                Button(action:{
                                    Task{
                                        comments = await commentHandler.deleteComment(commentId: comment.id, comments: comments)
                                        
                                    }
                                }){
                                    Image(systemName: "trash")
                                        .foregroundStyle(Color.red)
                                }
                            }
                            
                        }
                        .padding(.top, 5)
                        CommentElement(comment: comment)
                    }
                }
                .padding(.bottom, 30)
                
                
                //delete post button
                if(post.user_id == authHandler.user!.id){
                    
                    Button(action: {
                        presentDeleteAlert.toggle()
                    }){
                        Text(postHandler.isLoading ? "Deleting..." :"Delete Post")
                            .frame(maxWidth: .infinity)
                            .frame(height: 20)
                            .tint(.white)
                        
                        
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.red)
                            .stroke(Color.red.opacity(0.5), lineWidth: 2)
                    )
                    .alert(isPresented: $presentDeleteAlert){
                        Alert(title: Text("Delete Post"), message: Text("Are you sure you want to delete this post?"), primaryButton: .destructive(Text("Delete")){
                            Task{
                                Task{
                                    await postHandler.deletePost(post: post)
                                }
                            }
                        }, secondaryButton: .cancel())
                    }
                    
                }
            }
            .padding()
            .padding(.bottom, 60)
            
            
            
        }
        .scrollDismissesKeyboard(.interactively)

        .task {
            liked = await likeHander.checkUserLikeOnPost(postId: post.id, userId: authHandler.user!.id)
            comments = await commentHandler.getComments(postId: post.id)
            
            user = await authHandler.getOtherUserFromId(id: post.user_id)
            
            
            guard post.media_type == "video" else { return }
            
            if let videoPath = await postHandler.getVideoUpload(postId: post.id),
               let videoURL = postHandler.imageURL(path: videoPath) {
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
    }
}
