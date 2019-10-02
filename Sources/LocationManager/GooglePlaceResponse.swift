//
//  GooglePlaceResponse.swift
//  GoPump
//
//  Created by Apostolos Apostolidis on 2019-06-30.
//  Copyright © 2019 Apostolos Apostolidis. All rights reserved.
//

import Foundation

public class PlusCode: Decodable {
    var compound_code: String
    var global_code: String
}

public class AddressComponent: Decodable {
    var long_name: String
    var short_name: String
    var types: [String]
}

public class PlaceLocation: Decodable {
    var location: PlaceCoordinates?
    var location_type: String?
    var viewport: Viewport?
}

public class PlaceCoordinates: Decodable {
    var lat: Double
    var lng: Double
}

public class Viewport: Decodable {
    var northeast: PlaceLocation
    var southwest: PlaceLocation
}

public class PlaceResult: Decodable {
    var address_components: [AddressComponent]
    var formatted_address: String
    var geometry: PlaceLocation
}

public class GooglePlaceResponse: Decodable {
    var plus_code: PlusCode
    var results: [PlaceResult]
    var status: String
}
