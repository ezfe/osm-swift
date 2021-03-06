import Foundation
import SWXMLHash

public struct Coordinate: Hashable, Equatable, Codable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    private func radians(degrees: Double) -> Double {
        return degrees * Double.pi / 180.0
    }
    
    public func distance(to: Coordinate) -> Double {
        let earthRadius = 6_371_000.0 // meters
        
        let deltaLatitude = radians(degrees: to.latitude - self.latitude)
        let deltaLongitude = radians(degrees: to.longitude - self.longitude)
        
        let a: Double = pow(sin(deltaLatitude / 2), 2) + cos(radians(degrees: self.latitude)) * cos(radians(degrees: to.latitude)) * pow(sin(deltaLongitude / 2), 2)
        let c: Double = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return earthRadius * c
    }
}

extension Coordinate: CustomStringConvertible {
    public var description: String {
        return "{lat: \(latitude), lon: \(longitude)}"
    }
}

public struct Rect: Equatable, Hashable, Codable {
    public let min: Coordinate
    public let max: Coordinate
    
    /**
     * Create a rect with two coordinates
     * automatically normalizes coordinates into a min and max
     */
    public init(_ a: Coordinate, _ b: Coordinate) {
        self.min = Coordinate(latitude: Swift.min(a.latitude, b.latitude),
                              longitude: Swift.min(a.longitude, b.longitude))
        self.max = Coordinate(latitude: Swift.max(a.latitude, b.latitude),
                              longitude: Swift.max(a.longitude, b.longitude))
    }
    
    public var mapURL: URL {
        return URL(string: "https://api.openstreetmap.org/api/0.6/map?bbox=\(min.longitude),\(min.latitude),\(max.longitude),\(max.latitude)")!
    }
    
    public func contains(point: Coordinate) -> Bool {
        let latitudeOK = min.latitude < point.latitude && max.latitude > point.latitude
        let longitudeOK = min.longitude < point.longitude && max.longitude > point.longitude
        
        return latitudeOK && longitudeOK
    }
}

#if canImport(CoreLocation)

import CoreLocation

public extension CLLocationCoordinate2D {
    static func from(coordinate: Coordinate) -> Self {
        return CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

#endif
