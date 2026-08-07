//
//  ImageCache.swift
//  caravyn
//
//  Created by Ty Dickson on 8/7/26.
//

import Foundation
import UIKit

import SwiftUI

actor ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    
    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url.absoluteString as NSString)
    }
    
    func insert(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url.absoluteString as NSString)
    }
}

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    
    let url: URL?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder
    
    @State private var uiImage: UIImage?
    @State private var loadFailed = false
    
    var body: some View {
        if let uiImage {
            content(Image(uiImage: uiImage))
        } else if loadFailed {
            placeholder()
        } else {
            placeholder()
                .task(id: url) {
                    await load()
                }
        }
    }
    
    private func load() async {
        guard let url else {
            loadFailed = true
            return
        }
        
        // check cache first
        if let cached = await ImageCache.shared.image(for: url) {
            uiImage = cached
            return
        }
        
        // not cached — download
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let downloaded = UIImage(data: data) else {
                loadFailed = true
                return
            }
            await ImageCache.shared.insert(downloaded, for: url)
            uiImage = downloaded
        } catch {
            loadFailed = true
        }
    }
}
