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
    @StateObject private var locationManager = LocationManager()
    
    @State private var position: MapCameraPosition = .automatic
    @State private var zoomLevel: Double = 112.60658752186015
    
    var body: some View {
        Map(position: $position) {
            ForEach(groupHandler.postHandler.posts.filter { $0.coordinate != nil }) { post in

                if zoomLevel < 0.30 {

                    Annotation("", coordinate: post.coordinate!) {
                        PostElement(post: post, groupHandler: groupHandler)
                    }

                    MapCircle(center: post.coordinate!, radius: 10)
                        .foregroundStyle(Color.dark.opacity(0.3))

                } else {

                    Annotation("", coordinate: post.coordinate!) {
                        Image(systemName: "mappin")
                            .font(.title)
                            .foregroundStyle(.dark)
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
