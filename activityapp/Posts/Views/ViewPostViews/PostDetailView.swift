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
    
    @State var post: Post
    @State var liked = false
    
    @State var userId: String? = nil
    @State var otherUser: AppUser? = nil
    
    @State var username = "Loading..."
    
    @State var newComment: String = ""
    @State var comments: [Comment] = []
    var commentService = CommentService()
    @State var commentLoading = false
    
    @EnvironmentObject var postStore: PostStore
    @EnvironmentObject var authStore: AuthStore
    var likeService = LikeService()
    var userService = UserService()
    
    var backendService = BackendService()
    
    var dateFormatterService = DateFormatterService()

    var body: some View {
        ScrollView{
            VStack{
                MediaElement(post: $post)
                Text(post.caption)
                    .padding(.bottom, 20)
                
                
                HStack{
                    if let otherUser {
                        NavigationLink {
                            OtherUserView(user: otherUser)
                        } label: {
                            HStack {
                                Text(otherUser.username)
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
                    Text(dateFormatterService.formattedDate(post.created_at))
                    Spacer()
                    LikeElement(post: $post)
                }
                
                //comment text field
                HStack{
                    TextField("Add a comment", text: $newComment)
                    Button(action:{
                        Task{
                            guard let userId = await authStore.user?.id else {
                                return
                            }
                            commentLoading = true
                            if let commentN = await commentService.addComment(postId: post.id, userId: userId, comment: newComment, backendService: backendService) {
                                comments.append(commentN)
                            }
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
                            if(comment.user_id == userId){
                                Button(action:{
                                    Task{
                                        let deletedComment = await commentService.deleteComment(commentId: comment.id)

                                        comments = comments.filter{$0.id != comment.id}
                                            
                                        
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
                if(post.user_id == authStore.user!.id){
                    DeletePostButton(post: post)
                }
            }
            .padding()
            .padding(.bottom, 60)
            
            
            
        }
        .scrollDismissesKeyboard(.interactively)

        .task {
            userId = authStore.user?.id
            
            comments = await commentService.getPostComments(postId: post.id)
            
            do {
                otherUser = try await userService.getProfile(userId: post.user_id)
            } catch {
                return
            }
            
            
        }
    }
}
