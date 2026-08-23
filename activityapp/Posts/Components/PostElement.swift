//
//  PostElement.swift
//  activityapp
//
//  Created by Ty Dickson on 6/5/26.
//
import SwiftUI

struct PostElement: View {
    
    let post: Post
    let type: Bool
    var retreivePostService = RetrievePostService()
    
    var body: some View{
        ZStack(alignment: .bottom){

            
            VStack(spacing: 0) {
                NavigationLink {
                    PostDetailView(post: post)
                } label: {
                    if let media = post.media_url {
                        CachedAsyncImage(
                            url: retreivePostService.imageURL(path: media)
                        ) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 55, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } placeholder: {
                            ProgressView()
                                .frame(width: 55, height: 100)
                        }
                        .onAppear {
                            print("IMAGE PATH:", media)
                            print("RESOLVED URL:", retreivePostService.imageURL(path: media) as Any)
                        }
                    }
                }
                .padding(3)
                .background(type ? Color.lightBlue : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(type ? Color.lightBlue.opacity(0.8) : Color.white.opacity(0.8), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                // Triangle pointer
                /*
                Triangle()
                    .fill(Color.white)
                    .frame(width: 14, height: 8)
                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                 */
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
