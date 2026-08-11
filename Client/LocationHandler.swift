//
//  LocationHandler.swift
//  activityapp
//
//  Created by Ty Dickson on 5/31/26.
//

import CoreLocation
import SwiftUI
internal import Combine

@MainActor
final class LocationHandler:
    NSObject,
    ObservableObject,
    CLLocationManagerDelegate {

    private let manager = CLLocationManager()

    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    var latitude: Double { location?.coordinate.latitude ?? 0.0 }
    var longitude: Double { location?.coordinate.longitude ?? 0.0 }

    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    


    override init() {
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
        // No automatic permission request here — call requestPermission()
        // explicitly from PermissionsOnboardingView.
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func recenter() {
        manager.startUpdatingLocation()
    }
    
    func stopTracking(){
        manager.stopUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        if isAuthorized {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let latest = locations.last, latest.horizontalAccuracy < 100 else { return }
        location = latest
        manager.stopUpdatingLocation()
    }
    
    
}
