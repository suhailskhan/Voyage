import SwiftUI

struct SatelliteList: View {
    @Environment(ModelData.self) var modelData
    @State private var isLoading = false
    
    var shownSatellites: [Satellite] {
        modelData.satellites
    }
    
    var body: some View {
        NavigationSplitView {
            
            List(shownSatellites) { satellite in
                NavigationLink {
                    SatelliteDetail(satellite: satellite)
                } label: {
                    SatelliteRow(satellite: satellite)
                }
            }
            .navigationTitle("Satellites")
            .overlay {
                if modelData.isLoading {
                    ProgressView()
                }
            }
        } detail: {
            Text("Select a satellite")
        }
        .refreshable {
            modelData.reloadSatellites()
        }
    }
}

#Preview {
    SatelliteList()
        .environment(ModelData())
}
