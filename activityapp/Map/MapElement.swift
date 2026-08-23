//
//  MapView.swift
//  caravyn
//
//  Created by Ty Dickson on 6/16/26.
//
import SwiftUI
import MapKit

struct MapElement: View {
    
    @EnvironmentObject var authStore: AuthStore
    @StateObject var locationManager = LocationHandler()
    @EnvironmentObject var postStore: PostStore
    @EnvironmentObject var friendStore: FriendStore
    
    @State var publicPosts: Bool = true
    
    @State private var position: MapCameraPosition = .automatic
    @State private var zoomLevel: Double = 112.60658752186015
    @State private var currentRegion: MKCoordinateRegion?
    
    // cached, precomputed annotation data — only recalculated on real triggers
    @State private var visiblePosts: [(post: Post, isRecent: Bool)] = []
    
    func isLessThanOneDayOld(_ timestamp: String) -> Bool {
        let formats = [
            "yyyy-MM-dd HH:mm:ss.SSSSSSX",
            "yyyy-MM-dd HH:mm:ssX",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSX",
            "yyyy-MM-dd'T'HH:mm:ssX"
        ]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: timestamp) {
                return Date().timeIntervalSince(date) < 86400
            }
        }
        return false
    }
    
    func recomputeVisiblePosts() {
        let source = publicPosts ? postStore.friendPosts : postStore.publicPosts
        
        var filtered = source.compactMap { post -> (Post, Bool)? in
            guard post.coordinate != nil else { return nil }
            return (post, isLessThanOneDayOld(post.created_at))
        }
        
        // region-bound filtering, if we have a region yet
        if let region = currentRegion {
            let latDelta = region.span.latitudeDelta
            let lonDelta = region.span.longitudeDelta
            let minLat = region.center.latitude - latDelta
            let maxLat = region.center.latitude + latDelta
            let minLon = region.center.longitude - lonDelta
            let maxLon = region.center.longitude + lonDelta
            
            filtered = filtered.filter { post, _ in
                guard let coord = post.coordinate else { return false }
                return coord.latitude >= minLat && coord.latitude <= maxLat &&
                       coord.longitude >= minLon && coord.longitude <= maxLon
            }
        }
        
        visiblePosts = filtered.map { (post: $0.0, isRecent: $0.1) }
    }
    
    var body: some View {
        Map(position: $position) {
            MapContents(visiblePosts: visiblePosts, zoomLevel: zoomLevel, postStore: postStore)
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            zoomLevel = context.region.span.latitudeDelta
            currentRegion = context.region
            recomputeVisiblePosts()
        }
        .onReceive(locationManager.$location) { location in
            guard let location else { return }
            let region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            position = .region(region)
            currentRegion = region
            recomputeVisiblePosts()
        }
        .onChange(of: publicPosts) { _, _ in
            recomputeVisiblePosts()
        }
        .onChange(of: postStore.publicPosts) { _, _ in
            recomputeVisiblePosts()
        }
        .onChange(of: friendStore.friends) { _, _ in
            recomputeVisiblePosts()
        }
        .onChange(of: postStore.friendPosts) { _, _ in
            recomputeVisiblePosts()
        }
        .onAppear {
            if(friendStore.friends.count == 0){
                Task{

                    recomputeVisiblePosts()
                }
            }
            
        }
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing){
            ButtonsElement(locationManager: locationManager, publicPost: $publicPosts)
        }
    }
}
