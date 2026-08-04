//
//  NewPostView.swift
//  caravyn
//
//  Created by Ty Dickson on 8/3/26.
//

import SwiftUI

struct NewPostView: View {
    
    @State var showCamera = true
    
    @State private var capturedMedia: CameraResult?
    @StateObject private var postHandler = PostsHandler()
    
    @EnvironmentObject var authHandler: AuthHandler
    @EnvironmentObject var groupHandler: GroupsHandler
    @EnvironmentObject var locationHandler: LocationHandler
    
    var body: some View{
        VStack {
            if let media = capturedMedia {
                PostPreviewElement(
                    media: media,
                    postHandler: postHandler,
                    userId: authHandler.user!.id,
                    groupId: groupHandler.selectedGroup!/* current group id */,
                    latitude: locationHandler.latitude,
                    longitude: locationHandler.longitude/* current long */,
                    isPublicPost: true
                ) {
                    capturedMedia = nil
                    // navigate away / dismiss, etc.
                }
            } else {
                Text("Post View")
            }
        }
        .sheet(isPresented: $showCamera) {
            NewCameraView { result in
                capturedMedia = result
            }
        }
    }
}
