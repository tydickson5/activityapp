//
//  DeletePostButton.swift
//  caravyn
//
//  Created by Ty Dickson on 8/21/26.
//

import SwiftUI

struct DeletePostButton: View {
    
    @State private var presentDeleteAlert: Bool = false
    var post: Post
    
    @EnvironmentObject var postStore: PostStore
    
    var body: some View {
        Button(action: {
            presentDeleteAlert.toggle()
        }){
            Text(postStore.isLoading ? "Deleting..." :"Delete Post")
                .frame(maxWidth: .infinity)
                .frame(height: 20)
                .tint(.white)
            
            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.red)
                .stroke(Color.red.opacity(0.5), lineWidth: 2)
        )
        .alert(isPresented: $presentDeleteAlert){
            Alert(title: Text("Delete Post"), message: Text("Are you sure you want to delete this post?"), primaryButton: .destructive(Text("Delete")){
                Task{
                    Task{
                        await postStore.deletePost(post: post)
                    }
                }
            }, secondaryButton: .cancel())
        }
    }
}
