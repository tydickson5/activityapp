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
    
    @State private var page = "Image"
    
    var body: some View{
        
        VStack{
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
            
            if page == "Image" {
                ImageView()
            } else if page == "Video" {
                VidView()
            } else {
                UploadView()
            }
        }
        .padding()
        
        
        
    }
    
}
