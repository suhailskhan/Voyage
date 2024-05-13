import SwiftUI

class SatelliteDataViewModel: ObservableObject {
    @Published var satellites: [SatelliteData] = []
    @Published var isLoading = false

    func fetchSatellites() {
        guard let url = URL(string: "https://tle.ivanstanojevic.me/api/tle") else {
            print("Invalid URL")
            return
        }

        isLoading = true
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            defer { DispatchQueue.main.async { self?.isLoading = false } }
            
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            guard let data = data else {
                print("No data returned")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(TLECollection.self, from: data)
                DispatchQueue.main.async {
                    self?.satellites = decodedResponse.member
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        task.resume()
    }
}
