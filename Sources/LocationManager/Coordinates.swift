//
//  Coordinates.swift
//  GoPump
//
//  Created by Apostolos Apostolidis on 2019-06-30.
//  Copyright © 2019 Apostolos Apostolidis. All rights reserved.
//

import Foundation
import MapKit

/**
Enables easier use of coordinates and in various formats
 */
public class Coordinates: NSObject, Comparable {
    var latitude: Double
    var longitude: Double
    static let empty = Coordinates(withLatitude: 0.0, andLongitude: 0.0)
    
    /**
     String representation
     */
    public override var description: String {
        return "\(latitude)|\(longitude)"
    }
    
    /**
     String representation
     */
    public var stringFormat: String {
        return "\(latitude)|\(longitude)"
    }

    /**
     Dictionary representation
     */
    public var dictionaryFormat: [String: Double] {
        return ["Latitude": latitude, "Longitude": longitude]
    }
    
    /**
     CLLocationCoordinate representation for use with Apple APIs
     */
    public var clLocationFormat: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    /**
     The string has to be in of the format '{Latitude}|{Longitude}'.
     Example: '37.6270|47.2270'
     */
    public init?(fromString string: String) {
        let coordinates = string.split(separator: "|")
        guard coordinates.count == 2,
            let latitudeString = coordinates.first,
            let longitudeString = coordinates.last,
            let latitude = Double(String(latitudeString)),
        let longitude = Double(String(longitudeString))
        else {
            return nil
        }
        self.latitude = latitude
        self.longitude = longitude
    }
    
    
    /**
     Use Double type for both latitude and longitude
     */
    public init(withLatitude latitude: Double, andLongitude longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    /**
     Use a dictionary with value keys 'Latitude' & 'Longitude'
     */
    public init?(fromDict dict: [String: Any]) {
        guard let asDouble = Coordinates.extractFrom(doubles: dict)
            else {
                guard let asDouble = Coordinates.extractFrom(validStrings : dict)
                    else {
                        return nil
                }
                self.latitude = asDouble.0
                self.longitude = asDouble.1
                return
        }
        self.latitude = asDouble.0
        self.longitude = asDouble.1
    }
    
    private static func extractFrom(doubles dict: [String: Any]) -> (Double, Double)? {
        guard let latitude = dict["Latitude"] as? Double,
            let longitude = dict["Longitude"] as? Double
            else {
                return nil
        }
        return (latitude, longitude)
    }
    
    private static func extractFrom(validStrings dict: [String: Any]) -> (Double, Double)? {
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
    
    public static func == (lhs: Coordinates, rhs: Coordinates) -> Bool {
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
