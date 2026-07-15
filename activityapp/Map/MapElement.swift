//
//  MapView.swift
//  caravyn
//
//  Created by Ty Dickson on 6/16/26.
//
import SwiftUI
import MapKit

struct MapElement: View {
    
    @EnvironmentObject var groupHandler: GroupsHandler
    @EnvironmentObject var authHandler: AuthHandler
    @StateObject var locationManager =  LocationHandler()
    @EnvironmentObject var postHandler: PostsHandler  // add this
    
    
    @State private var position: MapCameraPosition = .automatic
    @State private var zoomLevel: Double = 112.60658752186015
    
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
    
    var body: some View {
        Map(position: $position) {
            ForEach(postHandler.posts.filter { $0.coordinate != nil }) { post in

                if zoomLevel < 0.30 || isLessThanOneDayOld(post.created_at) {

                    Annotation("", coordinate: post.coordinate!) {
                        PostElement(post: post, type: isLessThanOneDayOld(post.created_at))
                            .environmentObject(postHandler)
                    }

                    MapCircle(center: post.coordinate!, radius: 10)
                        .foregroundStyle(Color.dark.opacity(0.3))

                } else {

                    Annotation("", coordinate: post.coordinate!) {
                        Image(systemName: "mappin")
                            .font(.title)
                            .foregroundStyle(Color.pin)
                            .frame(width: 50, height: 50)
                    }

                }
            }
        }
        .onMapCameraChange { context in
            zoomLevel = context.region.span.latitudeDelta
        }
        .onReceive(locationManager.$location) { location in
            guard let location else { return }
            position = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing){
            ButtonsElement(locationManager: locationManager)
                
        }
    }
    
}
