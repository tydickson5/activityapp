//
//  NewPostView.swift
//  caravyn
//
//  Created by Ty Dickson on 8/3/26.
//

import SwiftUI

struct NewPostView: View {
    
    @State var showCamera = true
    
    var body: some View{
        VStack{
            Text("Post View")
        }
        .sheet(isPresented: $showCamera){
            NewCameraView{ result in
                switch result {
                case .photo(let image):
                    print(image)
                case .video(let url):
                    print(url)
                }
            }
        }
    }
}
