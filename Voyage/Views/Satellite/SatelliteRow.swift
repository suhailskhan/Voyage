import SwiftUI

struct SatelliteRow: View {
    var satellite: Satellite
    
    var body: some View {
        HStack {
            Image("satellite-icon")
            Text(satellite.name)
            Spacer()
        }
    }
}

#Preview {
    let satellites = ModelData().satellites
    return Group {
        SatelliteRow(satellite: satellites[0])
        SatelliteRow(satellite: satellites[1])
    }
}
