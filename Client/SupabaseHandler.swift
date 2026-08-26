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
    
    static let ipAddress: String =  "192.168.68.63"
    
    static let localBackendURL: String = "http://\(ipAddress):3000"
    
    static let productionBackendURL: String = "https://activityapp-backend.fly.dev"
    
    //dev prod
    #if true
        #if DEBUG
        static let backendURL = localBackendURL
        static let supabaseURL = "https://coeythfyfwzrwzuqowfe.supabase.co"
        static let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvZXl0aGZ5Znd6cnd6dXFvd2ZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU4MTE3ODgsImV4cCI6MjEwMTM4Nzc4OH0.P21ym8X6sCtk_moZM0cXnPPws4LUR3Go6TfMxmN2iNc"
        #else
        static let backendURL = productionBackendURL
        static let supabaseURL = "https://vdxqfhrsuhmqdbpeqtbt.supabase.co"
        static let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkeHFmaHJzdWhtcWRicGVxdGJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwMzcwMzMsImV4cCI6MjA5MzYxMzAzM30.6My-s4mropLOelDfcl2KSQAX2gQI2QP0y4Db0pcLICg"
        #endif
    #else
    static let backendURL = productionBackendURL
    static let supabaseURL = "https://vdxqfhrsuhmqdbpeqtbt.supabase.co"
    static let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkeHFmaHJzdWhtcWRicGVxdGJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwMzcwMzMsImV4cCI6MjA5MzYxMzAzM30.6My-s4mropLOelDfcl2KSQAX2gQI2QP0y4Db0pcLICg"
    #endif
    
   
     
     
    /*
    
    
    */
    
    
    
    
    ///DO NOT COMMENT
    
    static let client = SupabaseClient(
        supabaseURL: URL(string: supabaseURL)!,
        supabaseKey: supabaseKey
    )

}
