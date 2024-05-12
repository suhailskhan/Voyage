import Foundation
import _MapKit_SwiftUI

struct SatelliteContainer: Decodable {
    let satellites: [Satellite]
    
    enum CodingKeys: String, CodingKey {
        case satellites = "member"
    }
}

@Observable
class ModelData {
    var satellites: [Satellite] = []
    var isLoading = false
    
    init() {
        loadSatellites()
    }
    
    init(dummy: Bool) {
        if dummy {
            self.isLoading = true
            defer { self.isLoading = false }
            self.satellites = dummyLoad()
        } else {
            loadSatellites()
        }
    }
    
    func loadSatellites() {
        self.isLoading = true
        load(from: "https://tle.ivanstanojevic.me/api/tle/") { (result: Result<SatelliteContainer, Error>) in
            defer { self.isLoading = false }
            switch result {
            case .success(let container):
                self.satellites = container.satellites
                print("\(self.satellites[0].location.coordinate)")
            case .failure(let error):
                print("Failed to load satellites:", error)
            }
        }
    }
    
    func reloadSatellites() {
        loadSatellites()
    }
    
}

func load<T: Decodable>(from urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
    guard let url = URL(string: urlString) else {
        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        guard let data = data else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            }
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            DispatchQueue.main.async {
                completion(.success(decoded))
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }.resume()
}

func dummyLoad() -> [Satellite] {
    let jsonString = """
    [
        {
            "satelliteId": 1,
            "@type": "Tle",
            "@id": "http://example.com/1",
            "name": "Hubble",
            "date": "2024-05-10T10:45:00Z",
            "line1": "1 20580U 90037B   98267.54848650  .00001110  00000-0  52092-4 0  6882",
            "line2": "2 20580  28.4703  56.7238 0002336 280.6671  79.3422 15.09192856327537"
        },
        {
            "satelliteId": 2,
            "@type": "Tle",
            "@id": "http://example.com/2",
            "name": "ISS",
            "date": "2024-05-10T11:00:00Z",
            "line1": "1 25544U 98067A   20243.59791628  .00001243  00000-0  28348-4 0  9995",
            "line2": "2 25544  51.6410 207.0356 0001503 154.3063 255.3642 15.49114541234006"
        }
    ]
    """
    let jsonData = Data(jsonString.utf8)
    let decoder = JSONDecoder()
    do {
        let satellites = try decoder.decode([Satellite].self, from: jsonData)
        return satellites
    } catch {
        print("Failed to decode dummy satellites:", error)
        return []
    }
}
