//
//  CameraRepresentable.swift
//  caravyn
//
//  Created by Ty Dickson on 8/2/26.
//

import SwiftUI

struct CameraRepresentable: UIViewControllerRepresentable {
    
    let onCapture: (CameraResult) -> Void
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        vc.onCapture = onCapture
        return vc
    }
    
    func updateUIViewController(
        _ uiViewController: CameraViewController,
        context: Context
    ){}
}
