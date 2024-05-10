import Foundation

struct SatelliteContainer: Decodable {
    let satellites: [Satellite]
    
    enum CodingKeys: String, CodingKey {
        case satellites = "member"
    }
}

@Observable
class ModelData {
    var satellites: [Satellite] {
        let satelliteContainer: SatelliteContainer = load("data.json")
        return satelliteContainer.satellites
    }
}

func load<T: Decodable>(_ resource: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: resource, withExtension: nil)
    else {
        fatalError("Failed to locate \(resource) in bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Failed to load \(resource) from bundle: \n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Failed to parse \(resource) as \(T.self):\n\(error)")
    }
}
