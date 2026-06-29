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
    
    @State private var page = "Image"
    
    var body: some View{
        ZStack{
            VStack{
                HStack{
                    Menu{
                        Button {
                            page = "Image"
                        } label: {
                            Text("Image")
                        }
                        Button {
                            page = "Video"
                        } label: {
                            Text("Video")
                        }
                        Button {
                            page = "Upload"
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
                
                
                if page == "Image" {
                    ImageView()
                } else if page == "Video" {
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
                            .fill(Color.dark)
                    )
            }
        }
        
        
        
        
    }
    
}
