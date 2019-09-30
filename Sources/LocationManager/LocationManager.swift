//
//  LocationManager.swift
//  GoPump
//
//  Created by Apostolos Apostolidis on 2019-06-30.
//  Copyright © 2019 Apostolos Apostolidis. All rights reserved.
//

import CoreLocation
import Foundation

protocol LocationManagerDelegate {
    func locationManager(_ locationManager: LocationManager, didUpdateCurrentLocation location: Coordinates)
    func locationManagerDidNotUpdateLocation(_ locationManager: LocationManager)
}

public class LocationManager: NSObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?
    var running = false
    var delegate: LocationManagerDelegate?
    private let lockQueue = DispatchQueue(label: "LocationManager.lockQueue")
    fileprivate var _currentLocation: Coordinates?
    var currentLocation: Coordinates? {
        get {
            return lockQueue.sync {
                return _currentLocation
            }
        }
    }
    var timer: Timer?
    
    override init() {
        super.init()
        self.initializeCLLocationManager()
        self.startUpdatingLocation()
    }
    
    @objc func handleAppInUse() {
        if !self.running {
            self.startUpdatingLocation()
        }
    }
    
    public static let shared = LocationManager()
    
    @objc func startUpdatingLocation() {
        if let initializedLocationManager = locationManager {
            initializedLocationManager.startUpdatingLocation()
            initializedLocationManager.startMonitoringSignificantLocationChanges()
            self.running = true
            print("started updating Location")
        }
    }
    
    func initializeCLLocationManager() {
        locationManager = CLLocationManager()
        if let initializedLocationManager = locationManager {
            initializedLocationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
            initializedLocationManager.delegate = self
            initializedLocationManager.allowsBackgroundLocationUpdates = false
            initializedLocationManager.requestWhenInUseAuthorization()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error when updating location: \(error.localizedDescription)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locationManager?.location
            else {
                self.delegate?.locationManagerDidNotUpdateLocation(self)
                return
        }
        print("did get location: \(locations[0].coordinate.latitude) \(locations[0].coordinate.longitude)")
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let coordinates = Coordinates(withLatitude: latitude, andLongitude: longitude)
        self._currentLocation = coordinates
        self.delegate?.locationManager(self, didUpdateCurrentLocation: coordinates)
    }
    
    func findDistance(to point: Coordinates) -> Int {
        guard let startingLocation = self.currentLocation else {return 0}
        
        let pointLocation = CLLocation(latitude: point.latitude, longitude: point.longitude)
        let currentLocation = CLLocation(latitude: startingLocation.latitude, longitude: startingLocation.longitude)
        return Int(pointLocation.distance(from: currentLocation))
    }
}
