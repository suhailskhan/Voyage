import Foundation

struct TLECollection: Codable {
    var totalItems: Int
    var member: [SatelliteData]
}

struct SatelliteData: Codable, Identifiable {
    var id: String { satelliteId.description }
    var satelliteId: Int
    var name: String
    var date: String
    var line1: String
    var line2: String
}
