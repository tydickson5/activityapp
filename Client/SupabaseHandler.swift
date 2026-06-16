//
//  SupabaseHandler.swift
//  activityapp
//
//  Created by Ty Dickson on 5/7/26.
//

import Supabase
import Foundation

enum SupabaseHandler
{
    static let client = SupabaseClient(
        supabaseURL: URL(string: "https://vdxqfhrsuhmqdbpeqtbt.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkeHFmaHJzdWhtcWRicGVxdGJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwMzcwMzMsImV4cCI6MjA5MzYxMzAzM30.6My-s4mropLOelDfcl2KSQAX2gQI2QP0y4Db0pcLICg"
    )
    
    static let ipAddress: String =  "192.168.10.234"
    
    static let localBackendURL: String = "http://\(ipAddress):3000"
    
    static let productionBackendURL: String = "https://activityapp-backend.fly.dev"
    
    #if DEBUG
    static let backendURL = localBackendURL
    #else
    static let backendURL = productionBackendURL
    #endif
}
