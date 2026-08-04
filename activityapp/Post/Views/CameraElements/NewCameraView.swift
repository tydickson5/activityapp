//
//  NewCameraView.swift
//  caravyn
//
//  Created by Ty Dickson on 8/2/26.
//

import SwiftUI

struct NewCameraView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let onCapture: (CameraResult) -> Void
    
    var body: some View {
        CameraRepresentable { result in
            onCapture(result)
            dismiss()
        }
        .ignoresSafeArea()
    }
}
