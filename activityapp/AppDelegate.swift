//
//  AppDelegate.swift
//  activityapp
//
//  Created by Ty Dickson on 5/19/26.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject,
                   UIApplicationDelegate,
                   UNUserNotificationCenterDelegate {

    private(set) var deviceToken: String?
    var pendingPostId: String?
    
    weak var authHandler: AuthHandler? {
        didSet {
            if let userId = authHandler?.user?.id, deviceToken != nil {
                uploadToken(userId: userId)
            }
        }
    }
    
    weak var groupHandler: GroupsHandler?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        self.deviceToken = deviceToken.map {
            String(format: "%02.2hhx", $0)
        }.joined()
        print("APNs Token:", self.deviceToken!)

        if let userId = authHandler?.user?.id {
            uploadToken(userId: userId)
        } else {
            print("Token stored, waiting for login")
        }
    }

    func uploadToken(userId: String) {
        guard let token = deviceToken else {
            print("No device token yet")
            return
        }

        guard let url = URL(string: "\(SupabaseHandler.backendURL)/device-token") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "userId": userId,
            "deviceToken": token
        ])

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("Token upload failed:", error)
                return
            }
            print("Token uploaded successfully")
        }.resume()
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print(error)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("Silent push received:", userInfo)

        if let type = userInfo["type"] as? String,
           type == "notification_deleted",
           let notificationId = userInfo["notificationId"] as? String {
            UNUserNotificationCenter.current()
                .removeDeliveredNotifications(withIdentifiers: [notificationId])
        }

        completionHandler(.newData)
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("Notification tapped:", userInfo)

        if let postId = userInfo["postId"] as? String {
            pendingPostId = postId  // store it
            NotificationCenter.default.post(
                name: .notificationTapped,
                object: nil,
                userInfo: ["postId": postId]
            )
        }

        completionHandler()
    }
}

extension Notification.Name {
    static let notificationTapped = Notification.Name("notificationTapped")
}
