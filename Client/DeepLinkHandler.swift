//
//  DeepLinkHandler.swift
//  activityapp
//
//  Created by Ty Dickson on 6/4/26.
//

import Foundation
internal import Combine

@MainActor
final class DeepLinkHandler: ObservableObject {

    @Published var groupId: String?

    func handle(_ url: URL) {

        let components = url.pathComponents

        guard components.count >= 3 else {
            return
        }

        guard components[1] == "group" else {
            return
        }

        groupId = components[2]

        print("GROUP ID:", groupId!)
    }
}
