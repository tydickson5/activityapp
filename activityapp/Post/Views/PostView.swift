//
//  PostView.swift
//  activityapp
//
//  Created by Ty Dickson on 5/31/26.
//
import SwiftUI
import PhotosUI
import Photos

struct PostView: View{
    
    @EnvironmentObject var postHandler: PostsHandler
    
    @EnvironmentObject var authHandler: AuthHandler
    
    @State private var page = "image"
    @State private var openOnLoad = false
    
    var body: some View{
        ZStack{
            VStack{
                HStack{
                    Menu{
                        Button {
                            page = "image"
                        } label: {
                            Text("Image")
                        }
                        Button {
                            page = "video"
                        } label: {
                            Text("Video")
                        }
                        Button {
                            page = "upload"
                        } label: {
                            Text("Upload")
                        }
                    } label: {
                        HStack{
                            Text(page)
                                .foregroundStyle(Color.white)
                            Image(systemName: "chevron.down")
                                .foregroundStyle(Color.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.dark.opacity(0.9))
                        .clipShape(Capsule())
                    }
                    Spacer()
                    GroupPillSelectorElement()
                }
                
                
                if page == "image" {
                    ImageView()
                } else if page == "video" {
                    VidView()
                } else {
                    UploadView()
                }
            }
            .padding()
            if(postHandler.isLoading){
                ProgressView()
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.white)
                    )
            }
        }
        .task{
            if(authHandler.user!.user_default_view == "home"){
                page = "image"
            } else {
                page = authHandler.user!.user_default_view
                openOnLoad = true
            }
            
        }
        
        
        
    }
    
}
