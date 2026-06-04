//
//  CameraView.swift
//  activityapp
//
//  Created by Ty Dickson on 5/31/26.
//

import SwiftUI
import UIKit

struct CameraView:
    UIViewControllerRepresentable {

    @Binding var image: UIImage?

    func makeUIViewController(
        context: Context
    ) -> UIImagePickerController {

        let picker =
            UIImagePickerController()

        picker.delegate =
            context.coordinator

        picker.sourceType = .camera

        picker.mediaTypes = [
            "public.image"
        ]

        return picker
    }

    func updateUIViewController(
        _ uiViewController:
        UIImagePickerController,
        context: Context
    ) {}

    func makeCoordinator()
    -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator:
        NSObject,
        UINavigationControllerDelegate,
        UIImagePickerControllerDelegate {

        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker:
            UIImagePickerController,

            didFinishPickingMediaWithInfo info:
            [UIImagePickerController.InfoKey : Any]
        ) {

            if let image =
                info[.originalImage]
                as? UIImage {

                parent.image = image
            }

            picker.dismiss(
                animated: true
            )
        }

        func imagePickerControllerDidCancel(
            _ picker:
            UIImagePickerController
        ) {
            picker.dismiss(
                animated: true
            )
        }
    }
}
