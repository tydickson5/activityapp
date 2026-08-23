//
//  ImagePreviewElement.swift
//  caravyn
//
//  Created by Ty Dickson on 6/22/26.
//

import SwiftUI

struct ImagePreviewElement: View {
    
    var image: UIImage?
    
    var body: some View{
        
        Image(uiImage: image!)
            .resizable()
            .scaledToFit()
            .frame(
                height: 400
            )
            .clipShape(RoundedRectangle(cornerRadius: 25))
        
    }
    
}
