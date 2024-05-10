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
        } detail: {
            Text("Select a Landmark")
        }
    }
}

#Preview {
    SatelliteList()
        .environment(ModelData())
}
