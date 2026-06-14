//
//  HomeView.swift
//  activityapp
//
//  Created by Ty Dickson on 5/13/26.
//

import SwiftUI
import MapKit

struct HomeView: View {
    
    @EnvironmentObject var groupHandler: GroupsHandler
    @EnvironmentObject var authHandler: AuthHandler
    @StateObject private var locationManager = LocationManager()
    @ObservedObject private var postHandler: PostsHandler
        
    init(postHandler: PostsHandler) {
        self.postHandler = postHandler
    }
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var position: MapCameraPosition = .automatic
    @State private var zoomLevel: Double = 112.60658752186015
    
    var body: some View {
        NavigationStack {
            ZStack{
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
                    region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
                .ignoresSafeArea()
                .overlay(alignment: .topTrailing){
                    VStack{
                        Menu{
                            ForEach(groupHandler.groups){ group in
                                Button {
                                    groupHandler.selectedGroup = group.id
                                    Task{
                                        await groupHandler.updatedSelectedGroup(userId: authHandler.user!.id, groupId: group.id)
                                        await groupHandler.postHandler.getPosts(userId: authHandler.user!.id, groupId: group.id)
                                    }
                                    
                                } label: {
                                    Label(
                                        group.name,
                                        systemImage: group.id == groupHandler.selectedGroup
                                            ? "checkmark"
                                            : ""
                                    )
                                    
                                }
                                
                            }

                        } label: {
                            Image(systemName: "chevron.down")
                                .frame(width: 15, height: 15)
                                .foregroundStyle(Color.white)
                                .padding()
                                .background(Color.dark.opacity(0.9))
                                .clipShape(Circle())
                        }
                        Button(action:{
                            Task{
                                await groupHandler.postHandler.getPosts(userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!)
                            }
                        }){
                            Image(systemName: "arrow.clockwise")
                                .frame(width: 15, height: 15)
                                .foregroundStyle(Color.white)
                                .padding()
                                .background(Color.dark.opacity(0.9))
                                .clipShape(Circle())
                        }

                        
                    }
                    .padding()
                }
                
            }
            
        }
    }
}
