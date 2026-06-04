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

    private let manager =
        CLLocationManager()

    @Published var latitude = 0.0

    @Published var longitude = 0.0

    override init() {

        super.init()

        manager.delegate =
            self

        manager.requestWhenInUseAuthorization()

        manager.startUpdatingLocation()
    }

    func locationManager(
        _ manager:
            CLLocationManager,

        didUpdateLocations
        locations:
            [CLLocation]
    ) {

        guard let location =
            locations.last
        else {
            return
        }

        latitude =
            location
            .coordinate
            .latitude

        longitude =
            location
            .coordinate
            .longitude
    }
}
