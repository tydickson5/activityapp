//
//  LocationManager.swift
//  activityapp
//
//  Created by Ty Dickson on 6/3/26.
//

// LocationManager.swift
import CoreLocation
internal import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        manager.stopUpdatingLocation() // remove this if you want continuous updates
    }
}
