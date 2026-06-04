//
//  HomeView.swift
//  activityapp
//
//  Created by Ty Dickson on 5/13/26.
//

import SwiftUI
import MapKit

struct HomeView: View{
    
    @EnvironmentObject var groupHandler: GroupsHandler
    @EnvironmentObject var authHandler: AuthHandler
    

    
    @StateObject private var locationManager = LocationManager()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        
        NavigationStack {
            
            Map(
                coordinateRegion: $region,
                
                annotationItems: groupHandler.postHandler.posts.filter{$0.coordinate != nil}
                
                
            
            ){ post in
                MapAnnotation(coordinate: post.coordinate!){
                    NavigationLink {
                        PostDetailView(post: post, groupHandler: groupHandler)
                    } label: {
                        if let media = post.media_url {
                            

                            
                            AsyncImage(
                                url: groupHandler
                                    .postHandler
                                    .imageURL(
                                        path: post.media_url!
                                    )
                            ) { image in

                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(
                                        width: 55,
                                        height: 55
                                    )
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius: 12
                                        )
                                    )

                            } placeholder: {

                                ProgressView()
                                    
                            }
                            .onAppear {
                                print("IMAGE PATH:", media)
                                print("RESOLVED URL:", groupHandler.postHandler.imageURL(path: media) as Any)
                            }
                        }
                    }
                }
            }
            .task {

                

                await groupHandler
                    .postHandler
                    .getPosts(
                        userId: authHandler.user!.id, groupId: groupHandler.selectedGroup!,
                    )
                
                print("POST COUNT:", groupHandler.postHandler.posts.count)
            }
            .onReceive(locationManager.$location) { location in
                guard let location else { return }
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
            
        }
        
        
    }
}

