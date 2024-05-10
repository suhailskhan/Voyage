import Foundation

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
    
    func loadSatellites() {
        self.isLoading = true
        load(from: "https://tle.ivanstanojevic.me/api/tle/") { (result: Result<SatelliteContainer, Error>) in
            defer { self.isLoading = false }
            switch result {
            case .success(let container):
                self.satellites = container.satellites
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
