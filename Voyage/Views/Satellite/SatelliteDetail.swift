import SwiftUI
import CoreLocation
import MapKit

struct SatelliteDetail: View {
    var satellite: Satellite
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(satellite.name).font(.title).bold()
                
                Text("TLE Data").font(.headline)
                Text("Line 1: \(satellite.line1)")
                Text("Line 2: \(satellite.line2)")
                
                MapView(coordinate: satellite.location.coordinate)
                    .frame(height: 200)
            }
            .padding()
        }
        //        .navigationTitle(satellite.name)
        .navigationBarTitleDisplayMode(.automatic)
    }
}

#Preview {
    let modelData = ModelData()
    return SatelliteDetail(satellite: modelData.satellites[0])
        .environment(modelData)
}
