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
    
    @State private var caption: String = ""
    
    @State private var showCamera = false
    
    var body: some View{

        VStack{
            if let image {
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        height: 250
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            
            TextField("caption", text: $caption)
            
            Button("Take Photo"){
                showCamera = true
            }
                    
            Button("Upload"){
                Task{
                    
                    guard let image else {
                        return
                    }
                    
                    guard groupHandler
                        .selectedGroup != nil
                    else {
                        return
                    }
                    
                    
                    
                    
                    await groupHandler.postHandler.createPost(imageURL: image, userId: authHandler.user!.id, groupId: "70f2584b-8e91-4e3c-bf13-f915c098876b", caption: caption, latitude: locationHandler.latitude, longitude: locationHandler.longitude)
                    
                    await groupHandler.postHandler.getPosts(userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!)
                }
                
                
            }
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
                
        
            
        
    }
    
}
