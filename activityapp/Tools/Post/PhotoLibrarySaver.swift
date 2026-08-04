//
//  PhotoLibrarySaver.swift
//  caravyn
//
//  Created by Ty Dickson on 8/3/26.
//

import Photos
import UIKit

enum PhotoLibrarySaver {
    
    static func requestAddOnlyAuthorization(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                completion(status == .authorized || status == .limited)
            }
        }
    }
    
    static func save(image: UIImage, completion: ((Bool, Error?) -> Void)? = nil) {
        requestAddOnlyAuthorization { granted in
            guard granted else { completion?(false, nil); return }
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                DispatchQueue.main.async { completion?(success, error) }
            }
        }
    }
    
    static func save(videoURL: URL, completion: ((Bool, Error?) -> Void)? = nil) {
        requestAddOnlyAuthorization { granted in
            guard granted else { completion?(false, nil); return }
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            }) { success, error in
                DispatchQueue.main.async { completion?(success, error) }
            }
        }
    }
}
