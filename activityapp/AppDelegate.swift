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

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [.alert, .badge, .sound]
            ) { granted, error in

                DispatchQueue.main.async {
                    UIApplication.shared
                        .registerForRemoteNotifications()
                }
            }

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {

        let token = deviceToken.map {
            String(format: "%02.2hhx", $0)
        }.joined()

        print("APNs Token:", token)

        guard let url = URL(
            string: "http://192.168.10.119:3000/device-token"
        ) else {
            return
        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.addValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let body: [String: Any] = [
            "userId": "11911829-4c12-4b17-83e3-4563749b4cd4",
            "deviceToken": token
        ]

        request.httpBody = try? JSONSerialization
            .data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) {
            data,
            response,
            error in

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

    // foreground notifications

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    // silent delete pushes

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo:
        [AnyHashable : Any],
        fetchCompletionHandler completionHandler:
        @escaping (UIBackgroundFetchResult) -> Void
    ) {

        print("Silent push received:", userInfo)

        if let type = userInfo["type"] as? String,
           type == "notification_deleted",
           let notificationId = userInfo["notificationId"] as? String {

            UNUserNotificationCenter.current()
                .removeDeliveredNotifications(
                    withIdentifiers: [notificationId]
                )
        }

        completionHandler(.newData)
    }
}
