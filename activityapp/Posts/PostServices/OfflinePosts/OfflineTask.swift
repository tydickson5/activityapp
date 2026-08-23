//
//  OfflineTask.swift
//  caravyn
//
//  Created by Ty Dickson on 8/3/26.
//

import UIKit

extension PostStore{
    
    func runInBackground(_ work: @escaping () async -> Void) {
        var taskID: UIBackgroundTaskIdentifier = .invalid
        
        taskID = UIApplication.shared.beginBackgroundTask(withName: "PostUpload") {
            // Called if time runs out before work finishes
            UIApplication.shared.endBackgroundTask(taskID)
            taskID = .invalid
        }
        
        Task {
            await work()
            if taskID != .invalid {
                UIApplication.shared.endBackgroundTask(taskID)
                taskID = .invalid
            }
        }
    }
}
