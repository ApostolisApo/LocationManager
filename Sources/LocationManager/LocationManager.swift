//
//  LocationManager.swift
//  GoPump
//
//  Created by Apostolos Apostolidis on 2019-06-30.
//  Copyright © 2019 Apostolos Apostolidis. All rights reserved.
//

import CoreLocation
import Foundation
import RestManager

/**
 Conform to be able handle location related events from LocationManager
 */
public protocol LocationManagerDelegate {
    func locationManager(_ locationManager: LocationManager, didUpdateCurrentLocation location: Coordinates)
    func locationManagerDidNotUpdateLocation(_ locationManager: LocationManager)
    func locationManager(_ locationManager: LocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    func locationManager(_ locationManager: LocationManager, didGetAreaName name: String)
}

/**
 Functions as a wrapper for CLLocationManager and extends with additional functionality (e.g. getting area name for current location)
 */
public class LocationManager: NSObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?
    var running = false
    var googleGeocodeAPIKey: String?
    
    /**
     Assing this to an object so that it can handle various location events
     */
    public var delegate: LocationManagerDelegate?
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
    
    /**
     Provide the Google Geocode API key that you get from web console
     */
    public func setupGoogleGeocodeAPI(withKey key:String) {
        self.googleGeocodeAPIKey = key
    }
    
    @objc func handleAppInUse() {
        if !self.running {
            self.startUpdatingLocation()
        }
    }
    
    /**
     Access to the singleton instance
     */
    public static let shared = LocationManager()
    
    /**
     Request from the user permission to always track location
     */
    public func requestAlwaysPermission() {
        if let initializedLocationManager = locationManager {
            initializedLocationManager.requestAlwaysAuthorization()
        }
    }
    
    /**
     Request from the user permission to track location when your app is in use
     */
    public func requestWhenInUsePermission() {
        if let initializedLocationManager = locationManager {
            initializedLocationManager.requestWhenInUseAuthorization()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.delegate?.locationManager(self, didChangeAuthorization: status)
    }

    /**
     Start updating location, events must be handled through the delegate methods
     */
    @objc public func startUpdatingLocation() {
        if let initializedLocationManager = locationManager {
            initializedLocationManager.startUpdatingLocation()
            initializedLocationManager.startMonitoringSignificantLocationChanges()
            self.running = true
            print("started updating Location")
        }
    }
    
    fileprivate func initializeCLLocationManager() {
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
    
    /**
     Returns distance between to given Coordinate in meters
     */
    public func findDistance(to point: Coordinates) -> Int {
        guard let startingLocation = self.currentLocation else {return 0}
        
        let pointLocation = CLLocation(latitude: point.latitude, longitude: point.longitude)
        let currentLocation = CLLocation(latitude: startingLocation.latitude, longitude: startingLocation.longitude)
        return Int(pointLocation.distance(from: currentLocation))
    }
    
    /**
     Returns the nearest Coordinate
     */
    public func findNearest(from pointSet: [Coordinates]) -> Coordinates?{
        var nearestDistance: Int?
        var nearestCoordinates: Coordinates?
        
        for candidatePoint in pointSet {
            let distance = findDistance(to: candidatePoint)
            if nearestDistance == nil || distance < nearestDistance! {
                nearestDistance = distance
                nearestCoordinates = candidatePoint
            }
        }
        return nearestCoordinates
    }
    
    /**
     Returns area name for given Coordinates. Supplied by the Google Geolocator API.
     */
    public func getAreaName(forCoordinates coordinates: Coordinates) {
        guard let apiKey = self.googleGeocodeAPIKey,
            let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(coordinates.latitude),\(coordinates.longitude)&key=\(apiKey)")
            else {
                return
        }
        print("area name request: \(url)")
        RestManager().async(get: url, withTimeout: .normal){(result) in
            if let x = try? JSONDecoder().decode(GooglePlaceResponse.self, from: result){
                self.delegate?.locationManager(self, didGetAreaName: "\(x.results[0].address_components[2].long_name), \(x.results[0].address_components[3].long_name)")
            }
        }
    }
}

public extension LocationManagerDelegate {
    func locationManager(_ locationManager: LocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
    func locationManager(_ locationManager: LocationManager, didGetAreaName name: String) {
    }
}
