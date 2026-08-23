//
//  PermissionsOnboardView.swift
//  caravyn
//
//  Created by Ty Dickson on 7/10/26.
//

import SwiftUI
import UserNotifications

struct PermissionsOnboardView: View {
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var locationHandler: LocationHandler
    
    @State var showWelcomeOnboardView: Bool = false

    @State var notificationsEnabled = false
    @State var locationEnabled = false

    var onComplete: () -> Void
    

    var body: some View {
        if(showWelcomeOnboardView){
            //WelcomeOnboardView(showWelcomeOnboardView: $showWelcomeOnboardView)
        } else {
            VStack(spacing: 24) {
                Spacer()

                Text("Permissions")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Location permissions are need to use this app. Notifications permissions are recommended to know when friends post")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                permissionRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Get notified about posts, comments, and likes",
                    enabled: notificationsEnabled,
                    action: requestNotifications
                )

                permissionRow(
                    icon: "location.fill",
                    title: "Location",
                    subtitle: "See posts around the world",
                    enabled: locationEnabled,
                    action: requestLocation
                )

                Spacer()

                Button(action: finishOnboarding) {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                        .tint(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.dark)
                )
                .padding(.horizontal)

                Button("Skip for now", action: finishOnboarding)
                    .tint(.secondary)
                    .padding(.bottom)
            }
            .padding()
            .onAppear(perform: refreshStatuses)
        }
        
    }

    @ViewBuilder
    func permissionRow(icon: String, title: String, subtitle: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 36)
            VStack(alignment: .leading) {
                Text(title).fontWeight(.semibold)
                Text(subtitle).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Button(enabled ? "Enabled" : "Enable", action: action)
                .disabled(enabled)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.dark.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    func refreshStatuses() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
        locationEnabled = locationHandler.isAuthorized
    }

    func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                notificationsEnabled = granted
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    func requestLocation() {
        locationHandler.requestPermission()
        // If LocationHandler is a delegate-based CLLocationManager wrapper,
        // update `locationEnabled` from its @Published authorization status
        // instead of setting it here directly.
        locationEnabled = true
    }

    func finishOnboarding() {
        if let userId = authStore.user?.id {
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding_\(userId)")
        }
        onComplete()
    }
}
