//
//  Coordinates.swift
//  GoPump
//
//  Created by Apostolos Apostolidis on 2019-06-30.
//  Copyright © 2019 Apostolos Apostolidis. All rights reserved.
//

import Foundation
import MapKit

public class Coordinates: NSObject, Comparable {
    var latitude: Double!
    var longitude: Double!
    static let empty = Coordinates(withLatitude: 0.0, andLongitude: 0.0)
    
    public init(withLatitude latitude: Double, andLongitude longitude: Double) {
        super.init()
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public init?(fromDict dict: [String: Any]) {
        super.init()
        guard let asDouble = extractFrom(doubles: dict)
            else {
                guard let asDouble = extractFrom(validStrings : dict)
                    else {
                        return nil
                }
                setValues(forLatitude: asDouble.0, forLongitude: asDouble.1)
                return
        }
        setValues(forLatitude: asDouble.0, forLongitude: asDouble.1)
    }
    
    public func toDict() -> [String: Double] {
        return ["Latitude": latitude, "Longitude": longitude]
    }
    
    public func toString() -> String {
        guard let setLatitude = latitude,
            let setLongitude = longitude else {
                return ""
        }
        return "\(setLatitude), \(setLongitude)"
    }
    
    public func toCLLocationCoordinates() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    private func extractFrom(doubles dict: [String: Any]) -> (Double, Double)? {
        guard let latitude = dict["Latitude"] as? Double,
            let longitude = dict["Longitude"] as? Double
            else {
                return nil
        }
        return (latitude, longitude)
    }
    
    private func extractFrom(validStrings dict: [String: Any]) -> (Double, Double)? {
        guard let latitude = dict["Latitude"] as? String,
            let longitude = dict["Longitude"] as? String
            else {
                return nil
        }
        guard let latDouble = Double(latitude),
            let lonDouble = Double(longitude)
            else {
                return nil
        }
        return (latDouble, lonDouble)
    }
    
    private func setValues(forLatitude lat: Double, forLongitude lon: Double) {
        self.latitude = lat
        self.longitude = lon
    }
    
    static func == (lhs: Coordinates, rhs: Coordinates) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    public static func < (lhs: Coordinates, rhs: Coordinates) -> Bool {
        return lhs.latitude < rhs.latitude && lhs.longitude < rhs.longitude
    }
}

struct CoordinatesFrame {
    var minLat: Double
    var maxLat: Double
    var minLon: Double
    var maxLon: Double
}
