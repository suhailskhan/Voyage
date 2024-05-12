import Foundation
import CoreLocation
import SGPKit

/// Satellite data model.
/// Contains stored properties (sourced from JSON data provided by API), and computed properties derived from JSON data, including date and location.
struct Satellite: Codable, Identifiable {
    // Properties that correspond with each of the JSON keys
    var id: Int
    var type: String
    var url: String
    var name: String
    private var dateString: String
    var date: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: dateString) ?? Date.distantPast
    }
    var line1: String // These two are the Ls (lines) in TLE (two-line element)
    var line2: String
    
    /// Provides bindings between the above properties and the JSON keys found in the TLE API response.
    enum CodingKeys: String, CodingKey {
        case id = "satelliteId", type = "@type", url = "@id", name, dateString = "date", line1, line2
    }
    
    /// The following private variables are instances of objects provided by the SGPKit library.
    /// SGPKit will allow us to compute altitude, speed, latitude, and longitude given the TLE data strings (variables line1 and line2 as seen above).
    private var tle: TLE {
        return TLE(title: name, firstLine: line1, secondLine: line2)
    }
    private var interpreter = TLEInterpreter()
    
    /// Core Location object created using location and speed data computed with SGPKit.
    var location: CLLocation {
        let previousDate = Calendar.current.date(byAdding: .second, value: -10, to: date)!
        let previousLocation = locationAt(date: previousDate)
        let currentLocation = locationAt(date: date)
        
        return CLLocation(coordinate: currentLocation.coordinate,
                          altitude: currentLocation.altitude,
                          horizontalAccuracy: 1.0,
                          verticalAccuracy: 1.0,
                          course: calculateBearing(from: previousLocation.coordinate, to: currentLocation.coordinate),
                          speed: speedAt(time: date),
                          timestamp: date
        )
    }

    /// Companion function for the location property.
    /// - Parameter date: Date at which to calculate satellite locaton
    /// - Returns: Core Location object
    private func locationAt(date: Date) -> CLLocation {
        let data = interpreter.satelliteData(from: tle, date: date)
        return CLLocation(coordinate: CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude),
                          altitude: data.altitude,
                          horizontalAccuracy: 1.0,
                          verticalAccuracy: 1.0,
                          course: -1,
                          speed: data.speed,
                          timestamp: date
        )
    }
    /// Companion function for the location property.
    /// - Parameters:
    ///   - from: Starting location
    ///   - to: Ending location
    /// - Returns: CLLocationDirection object (Direction in degrees)
    private func calculateBearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDirection {
        let deltaLongitude = to.longitude - from.longitude
        let y = sin(deltaLongitude) * cos(to.latitude)
        let x = cos(from.latitude) * sin(to.latitude) - sin(from.latitude) * cos(to.latitude) * cos(deltaLongitude)
        let radiansBearing = atan2(y, x)
        let degreesBearing = radiansBearing * 180 / .pi
        return (degreesBearing + 360).truncatingRemainder(dividingBy: 360)
    }
    
    // Used to compute historic speed and altitude
    func altitudeAt(time: Date) -> CLLocationDistance {
        let data = interpreter.satelliteData(from: tle, date: time)
        return data.altitude
    }
    func speedAt(time: Date) -> CLLocationSpeed {
        let data = interpreter.satelliteData(from: tle, date: time)
        return data.speed
    }
}
