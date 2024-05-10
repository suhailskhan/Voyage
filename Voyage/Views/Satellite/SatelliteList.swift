import SwiftUI

struct SatelliteList: View {
    @Environment(ModelData.self) var modelData
    
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
        } detail: {
            Text("Select a satellite")
        }
    }
}

#Preview {
    SatelliteList()
        .environment(ModelData())
}
