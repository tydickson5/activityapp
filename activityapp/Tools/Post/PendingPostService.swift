//
//  PendingPostService.swift
//  caravyn
//
//  Created by Ty Dickson on 8/4/26.
//

import Foundation
import UIKit
internal import Combine

final class PendingPostService: ObservableObject {
    
    static let shared = PendingPostService()
    @Published private(set) var pendingPosts: [PendingPost] = []
    
    
    private let folder: URL = {
        let url = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("PendingPosts", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()
    
    private var indexURL: URL { folder.appendingPathComponent("index.json") }
    
    private init() {
        pendingPosts = loadIndex()
    }
    
    private func loadIndex() -> [PendingPost] {
        guard let data = try? Data(contentsOf: indexURL),
              let posts = try? JSONDecoder().decode([PendingPost].self, from: data)
        else { return [] }
        return posts
    }
    
    private func saveIndex(_ posts: [PendingPost]) {
        guard let data = try? JSONEncoder().encode(posts) else { return }
        try? data.write(to: indexURL, options: .atomic)
        DispatchQueue.main.async {
            self.pendingPosts = posts   // keeps @Published in sync with disk
        }
    }
    
    /// Saves an image + caption/metadata to disk and returns the queued PendingPost.
    func enqueueImage(image: UIImage, caption: String, userId: String, groupId: String, latitude: Double, longitude: Double, isPublicPost: Bool) -> PendingPost? {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
        let id = UUID().uuidString
        let filename = "\(id).jpg"
        try? data.write(to: folder.appendingPathComponent(filename))
        
        var timeStamp = getSupabaseTimestamp()
        
        let post = PendingPost(
            id: id, user_id: userId, group_id: groupId, caption: caption, media_url: filename, media_type: "image", latitude: latitude, longitude: longitude, public_post: isPublicPost, thumbnailFilename: nil, created_at: timeStamp
        )
        var posts = loadIndex()
        posts.append(post)
        saveIndex(posts)
        return post
    }
    
    /// Copies a video (and its thumbnail) into durable storage and queues it.
    func enqueueVideo(videoURL: URL, thumbnail: UIImage, caption: String, userId: String, groupId: String, latitude: Double, longitude: Double, isPublicPost: Bool) -> PendingPost? {
        let id = UUID().uuidString
        let videoFilename = "\(id).mov"
        let thumbFilename = "\(id)_thumb.jpg"
        
        guard let thumbData = thumbnail.jpegData(compressionQuality: 0.9) else { return nil }
        
        do {
            try FileManager.default.copyItem(at: videoURL, to: folder.appendingPathComponent(videoFilename))
            try thumbData.write(to: folder.appendingPathComponent(thumbFilename))
        } catch {
            print("Failed to persist pending video: \(error)")
            return nil
        }
        
        var timeStamp = getSupabaseTimestamp()
        
        let post = PendingPost(
            id: id, user_id: userId, group_id: groupId, caption: caption, media_url: videoFilename, media_type: "video", latitude: latitude, longitude: longitude, public_post: isPublicPost, thumbnailFilename: thumbFilename, created_at: timeStamp
        )
        var posts = loadIndex()
        posts.append(post)
        saveIndex(posts)
        return post
    }
    
    func allPending() -> [PendingPost] { loadIndex() }
    
    func remove(_ post: PendingPost) {
        var posts = loadIndex()
        posts.removeAll { $0.id == post.id }
        saveIndex(posts)
        try? FileManager.default.removeItem(at: folder.appendingPathComponent(post.media_url!))
        if let thumb = post.thumbnailFilename {
            try? FileManager.default.removeItem(at: folder.appendingPathComponent(thumb))
        }
    }
    
    func incrementAttempts(_ post: PendingPost) {
        var posts = loadIndex()
        if let idx = posts.firstIndex(where: { $0.id == post.id }) {
            posts[idx].attempts += 1
            saveIndex(posts)
        }
    }
    
    func fileURL(for filename: String) -> URL {
        folder.appendingPathComponent(filename)
    }
    
    func previewImage(for post: PendingPost) -> UIImage? {
        let filename = (post.media_type == "video" ? (post.thumbnailFilename ?? post.media_url) : post.media_url!)!
        return UIImage(contentsOfFile: fileURL(for: filename).path)
    }
    
    func getSupabaseTimestamp() -> String {
        let formatter = ISO8601DateFormatter()
        // Supabase uses format options: year, month, day, time, and timezone
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: Date())
    }
}
