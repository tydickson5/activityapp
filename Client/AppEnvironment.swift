//
//  AppEnvironment.swift
//  activityapp
//
//  Created by Ty Dickson on 5/7/26.
//

import Foundation
import SwiftUI

struct AppEnvironment {
    let supabaseUrl: String
    let supabaseAnonKey: String
}

extension AppEnvironment {
    static let live = AppEnvironment(
        supabaseUrl: "https://vdxqfhrsuhmqdbpeqtbt.supabase.co",
        supabaseAnonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkeHFmaHJzdWhtcWRicGVxdGJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwMzcwMzMsImV4cCI6MjA5MzYxMzAzM30.6My-s4mropLOelDfcl2KSQAX2gQI2QP0y4Db0pcLICg"
    )
}


private struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue = AppEnvironment.live
}

extension EnvironmentValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
