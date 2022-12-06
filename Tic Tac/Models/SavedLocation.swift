//
//  SavedLocation.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 11/6/22.
//

import Foundation

enum UserLocation: Equatable {
    case current
    case override(SavedLocation)
}

class SavedLocation: Codable, Equatable {
    struct Coordinate: Codable {
        var lat: Double
        var lng: Double
        
        var coordinate: CLLocationCoordinate2D {
            .init(latitude: lat, longitude: lng)
        }
    }
    
    let name: String
    let location: Coordinate
    
    init(name: String, location: CLLocationCoordinate2D) {
        self.name = name
        self.location = .init(lat: location.latitude, lng: location.longitude)
    }
    
    static func == (lhs: SavedLocation, rhs: SavedLocation) -> Bool {
        return lhs.name == rhs.name
    }
}
