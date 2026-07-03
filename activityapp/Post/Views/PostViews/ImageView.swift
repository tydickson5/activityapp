//
//  ImageView.swift
//  caravyn
//
//  Created by Ty Dickson on 6/22/26.
//
import SwiftUI

struct ImageView: View {
    
    @EnvironmentObject var groupHandler: GroupsHandler
    @EnvironmentObject var authHandler: AuthHandler
    @EnvironmentObject var postHandler: PostsHandler
    @EnvironmentObject var locationHandler: LocationHandler
    
    @State private var image: UIImage?
    @State private var showCamera = false
    
    @State private var caption: String = ""
    
    @State private var postToPublic: Bool = false
    @State private var showAlert: Bool = false
    
    func makePost() async{
        guard (image != nil) else {
            ToastManager.shared.error("No image")
            return
        }
        
        await postHandler.createImagePost(imageURL: image!, userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!, caption: caption, latitude: locationHandler.latitude, longitude: locationHandler.longitude, isPublicPost: postToPublic)
    }
    
    
    var body: some View {
        
        VStack{
            
            //preview element
            if let image {
                ImagePreviewElement(image: image)
            }
            
            Spacer()
            
            
            if(groupHandler.selectedGroup != "6ce9c8f8-2ff2-4f12-8f74-19671fcfb265"){
                HStack{
                    Text("Post to public")
                    Spacer()
                    Toggle("", isOn: $postToPublic)
                        .labelsHidden()
                        .onTapGesture {
                            print("clicked")
                        }
                }
            }
            
            //caption
            HStack{
                TextField("caption", text: $caption)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.lightBlue.opacity(0.5), lineWidth: 2)
                    )
                Button(action: {
                    Task{
                        showCamera = true
                    }
                }){
                    Image(systemName: "camera")
                        .foregroundStyle(Color.lightBlue)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.lightBlue.opacity(0.5), lineWidth: 2)
                )
            }
            
            
            //submit button
            Button(action: {
                Task{
                    guard groupHandler
                        .selectedGroup != nil
                    else {
                        return
                    }
                    
                    if(groupHandler.selectedGroup == "6ce9c8f8-2ff2-4f12-8f74-19671fcfb265"){
                        postToPublic = true
                    }
                    
                    if(postToPublic){
                        showAlert.toggle()
                    } else {
                        await makePost()
                        caption = ""
                        self.image = nil
                        postToPublic = false
                        await postHandler.getPosts(userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!)
                    }
                    
                    
                }
            }){
                Text(postHandler.isLoading ? "Loading..." :"Post")
                    .frame(maxWidth: .infinity)
                    .frame(height: 20)
                    .tint(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.dark)
                    .stroke(Color.dark.opacity(0.5), lineWidth: 2)
            )
            .alert(isPresented: $showAlert){
                Alert(title: Text("Post to public"), message: Text("Are you sure you want to post to the public group everyone can see?"), primaryButton: .destructive(Text("Yes").foregroundStyle(Color.lightBlue)){
                    Task{
                        await makePost()
                        caption = ""
                        self.image = nil
                        postToPublic = false
                        await postHandler.getPosts(userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!)
                    }
                }, secondaryButton: .cancel())
            }
            
        }
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
