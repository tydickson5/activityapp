//
//  PostUploadQueue.swift
//  caravyn
//
//  Created by Ty Dickson on 8/4/26.
//

import Foundation
import Network
import UIKit

actor InFlightTracker {
    private var ids = Set<String>()
    
    /// Attempts to claim an ID. Returns true if it was successfully claimed
    /// (i.e. wasn't already in flight), false if it's already being handled.
    func claim(_ id: String) -> Bool {
        guard !ids.contains(id) else { return false }
        ids.insert(id)
        return true
    }
    
    func release(_ id: String) {
        ids.remove(id)
    }
}

final class PostUploadQueue {
    
    static let shared = PostUploadQueue()
    
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "PostUploadQueue.monitor")
    private var isOnline = false
    private let maxAttempts = 50
    
    weak var postStore: PostStore?   // set this once, e.g. from your App init
    
    private let inFlightTracker = InFlightTracker()
    
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
        guard let postStore = postStore else { return }
        let pending = PendingPostService.shared.allPending()
        guard !pending.isEmpty else { return }
        
        for post in pending {
            Task {
                await attempt(post, postStore: postStore)
            }
        }
    }
    
    private func attempt(_ post: PendingPost, postStore: PostStore) async {
        guard post.attempts < maxAttempts else { return }
        
        guard await inFlightTracker.claim(post.id) else { return }
        
        let mediaURL = PendingPostService.shared.fileURL(for: post.media_url!)

        switch post.media_type {
        case "image":
            guard let image = UIImage(contentsOfFile: mediaURL.path) else { return }
            await postStore.createPost(isImagePost: true, postId: post.id,
                                           imageURL: image, videoURL: nil, userId: post.user_id, groupId: post.group_id,
                caption: post.caption, latitude: post.latitude!, longitude: post.longitude!,
                                           state: post.public_post ? "public" : "friends", created_at: post.created_at ?? nil
            )
        case "video":
            guard let thumbFilename = post.thumbnailFilename,
                  let thumbnail = UIImage(contentsOfFile: PendingPostService.shared.fileURL(for: thumbFilename).path)
            else { return }
            await postStore.createPost(isImagePost: false, postId: post.id, imageURL: nil,
                videoURL: mediaURL, userId: post.user_id,
                groupId: post.group_id, caption: post.caption, latitude: post.latitude!,
                                                  longitude: post.longitude!, state: post.public_post ? "public" : "friends", created_at: post.created_at ?? nil
            )
        default:
            return
        }
        
        // Success — remove from the durable queue
        PendingPostService.shared.remove(post)
            
    }
}
