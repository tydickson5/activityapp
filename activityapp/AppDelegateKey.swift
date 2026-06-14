//
//  AppDelegateKey.swift
//  activityapp
//
//  Created by Ty Dickson on 6/9/26.
//

import SwiftUI

private struct AppDelegateKey: EnvironmentKey {
    static let defaultValue: AppDelegate = AppDelegate()
}

extension EnvironmentValues {
    var appDelegate: AppDelegate {
        get { self[AppDelegateKey.self] }
        set { self[AppDelegateKey.self] = newValue }
    }
}
