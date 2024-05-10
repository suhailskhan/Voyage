import Foundation
import Combine
import SGPKit
import CoreLocation

struct Satellite: Codable, Identifiable {
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
    
    var line1: String
    var line2: String
    
    private var tle: TLE {
        return TLE(title: name, firstLine: line1, secondLine: line2)
    }
    
    private var interpreter = TLEInterpreter()
    private var interpretedData: SatelliteData {
        interpreter.satelliteData(from: tle, date: date)
    }
    
    var location: CLLocation {
        let previousDate = Calendar.current.date(byAdding: .second, value: -10, to: date)!
        let previousLocation = locationAt(date: previousDate)
        let currentLocation = locationAt(date: date)
        
        return CLLocation(coordinate: currentLocation.coordinate,
                          altitude: currentLocation.altitude,
                          horizontalAccuracy: 1.0,
                          verticalAccuracy: 1.0,
                          course: calculateBearing(from: previousLocation.coordinate, to: currentLocation.coordinate),
                          speed: interpretedData.speed,
                          timestamp: date
        )
    }
    
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
    
    private func calculateBearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDirection {
        let deltaLongitude = to.longitude - from.longitude
        let y = sin(deltaLongitude) * cos(to.latitude)
        let x = cos(from.latitude) * sin(to.latitude) - sin(from.latitude) * cos(to.latitude) * cos(deltaLongitude)
        let radiansBearing = atan2(y, x)
        let degreesBearing = radiansBearing * 180 / .pi
        return (degreesBearing + 360).truncatingRemainder(dividingBy: 360)
    }
    
    func altitudeAt(time: Date) -> CLLocationDistance {
        let data = interpreter.satelliteData(from: tle, date: time)
        return data.altitude
    }
    
    func speedAt(time: Date) -> CLLocationSpeed {
        let data = interpreter.satelliteData(from: tle, date: time)
        return data.speed
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "satelliteId", type = "@type", url = "@id", name, dateString = "date", line1, line2
    }
}
