//
//  NavigationHandler.swift
//  caravyn
//
//  Created by Ty Dickson on 7/3/26.
//

import SwiftUI
internal import Combine

@MainActor
class NavigationHandler: ObservableObject {
    @Published var selectedPost: Post?
}
