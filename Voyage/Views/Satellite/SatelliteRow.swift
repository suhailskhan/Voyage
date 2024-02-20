import SwiftUI

struct SatelliteRow: View {
    var satellite: Satellite
    
    var body: some View {
        HStack {
            Image("satellite")
            Text(satellite.name)
            Spacer()
        }
    }
}

#Preview {
    let satellites = ModelData(dummy: true).satellites
    return SatelliteRow(satellite: satellites[0])
}

#Preview {
    let satellites = ModelData(dummy: true).satellites
    return SatelliteRow(satellite: satellites[1])
}
