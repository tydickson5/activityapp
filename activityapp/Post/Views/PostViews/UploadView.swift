//
//  UploadView.swift
//  caravyn
//
//  Created by Ty Dickson on 6/22/26.
//

import SwiftUI
import Photos
import PhotosUI
import ImageIO
import CoreLocation

struct UploadView: View{
    
    

    func locationFromImageData(_ data: Data) -> CLLocation? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let gps = properties[kCGImagePropertyGPSDictionary] as? [CFString: Any]
        else {
            return nil
        }

        guard let lat = gps[kCGImagePropertyGPSLatitude] as? Double,
              let latRef = gps[kCGImagePropertyGPSLatitudeRef] as? String,
              let lon = gps[kCGImagePropertyGPSLongitude] as? Double,
              let lonRef = gps[kCGImagePropertyGPSLongitudeRef] as? String
        else {
            return nil
        }

        let latitude = latRef == "S" ? -lat : lat
        let longitude = lonRef == "W" ? -lon : lon

        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    @EnvironmentObject var groupHandler: GroupsHandler
    @EnvironmentObject var authHandler: AuthHandler
    @EnvironmentObject var postHandler: PostsHandler
    @EnvironmentObject var locationHandler: LocationHandler
    
    @State private var image: UIImage?
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var photoLocation: CLLocation?
    @State private var photoDate: Date?
    
    @State private var caption: String = ""
    
    @State private var postToPublic: Bool = false
    @State private var showAlert: Bool = false
    
    //@State private var showCoords = false
    
    func makePost() async{
        guard (image != nil) else {
            ToastManager.shared.error("No image")
            return
        }
        
        let latitude = photoLocation?.coordinate.latitude ?? locationHandler.latitude
        let longitude = photoLocation?.coordinate.longitude ?? locationHandler.longitude
        
        await postHandler.createImagePost(imageURL: image!, userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!, caption: caption, latitude: latitude, longitude: longitude, isPublicPost: postToPublic)
    }
    
    var body: some View {
        
        VStack{
            
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
                //upload
                PhotosPicker(selection: $selectedItem, matching: .images){
                    Image(systemName: "photo.on.rectangle.angled.fill")
                        .foregroundStyle(Color.lightBlue)
                        .padding()

                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.lightBlue.opacity(0.5), lineWidth: 2)
                )
                .onChange(of: selectedItem) { item in
                    Task {
                        guard let item else { return }

                        if let data = try? await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {

                            image = uiImage

                            // Try GPS directly from image metadata
                            photoLocation = locationFromImageData(data)

                            print("GPS from image:", photoLocation as Any)
                        }

                        // Still get creation date from PHAsset
                        if let identifier = item.itemIdentifier {
                            print("Identifier:", identifier)

                            let result = PHAsset.fetchAssets(
                                withLocalIdentifiers: [identifier],
                                options: nil
                            )

                            print("Found assets:", result.count)

                            if let asset = result.firstObject {
                                print("Asset location:", asset.location as Any)
                                print("Asset date:", asset.creationDate as Any)

                                photoLocation = asset.location
                                photoDate = asset.creationDate
                            }
                        }

                        print("Final photoLocation:", photoLocation as Any)
                    }
                }
                
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
                Text("Post")
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
    }
}
