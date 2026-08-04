//
//  PostUploadQueue.swift
//  caravyn
//
//  Created by Ty Dickson on 8/4/26.
//

import Foundation
import Network
import UIKit

final class PostUploadQueue {
    
    static let shared = PostUploadQueue()
    
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "PostUploadQueue.monitor")
    private var isOnline = false
    private let maxAttempts = 5
    
    weak var postHandler: PostsHandler?   // set this once, e.g. from your App init
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let wasOnline = self.isOnline
            self.isOnline = path.status == .satisfied
            if self.isOnline && !wasOnline {
                self.retryAll()
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    /// Call this once at launch (e.g. in your App's init or onAppear)
    /// to retry anything that was queued from a previous session.
    func retryAll() {
        guard let postHandler = postHandler else { return }
        let pending = PendingPostService.shared.allPending()
        guard !pending.isEmpty else { return }
        
        for post in pending {
            Task {
                await attempt(post, postHandler: postHandler)
            }
        }
    }
    
    private func attempt(_ post: PendingPost, postHandler: PostsHandler) async {
        guard post.attempts < maxAttempts else { return }
        
        let mediaURL = PendingPostService.shared.fileURL(for: post.media_url!)
        
        do {
            switch post.media_type {
            case "image":
                guard let image = UIImage(contentsOfFile: mediaURL.path) else { return }
                try await postHandler.createImagePost(
                    imageURL: image, userId: post.user_id, groupId: post.group_id,
                    caption: post.caption, latitude: post.latitude!, longitude: post.longitude!,
                    isPublicPost: post.public_post
                )
            case "video":
                guard let thumbFilename = post.thumbnailFilename,
                      let thumbnail = UIImage(contentsOfFile: PendingPostService.shared.fileURL(for: thumbFilename).path)
                else { return }
                try await postHandler.createVideoPost(
                    videoURL: mediaURL, thumbnailURL: thumbnail, userId: post.user_id,
                    groupId: post.group_id, caption: post.caption, latitude: post.latitude!,
                    longitude: post.longitude!, isPublicPost: post.public_post
                )
            default:
                return
            }
            
            // Success — remove from the durable queue
            PendingPostService.shared.remove(post)
            
        } catch {
            print("Retry failed for \(post.id): \(error)")
            PendingPostService.shared.incrementAttempts(post)
        }
    }
}
