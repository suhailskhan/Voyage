import SwiftUI
import CoreLocation
import MapKit

struct SatelliteDetail: View {
    var satellite: Satellite
    
    var body: some View {
        ScrollView {
            VStack() {
                HStack {
                    Text("Altitude:")
                    Spacer()
                    Text("\(satellite.location.altitude, specifier: "%.0f") km")
                }
                
                Spacer()
                
                SatelliteAltitudeChart(satellite: satellite)
                
                Spacer()
                
                HStack {
                    Text("Speed:")
                    Spacer()
                    Text("\(satellite.location.speed, specifier: "%.0f") km/h")
                }
                
                Spacer()
                
                SatelliteSpeedChart(satellite: satellite)

                Spacer()
                
                HStack(alignment: .bottom) {
                    Text("Date:")
                    Spacer()
                    Text("\(satellite.date, format: .dateTime.year().month().day())")
                }
            }
            .padding()
            .navigationTitle(satellite.name)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    let modelData = ModelData(dummy: true)
    return SatelliteDetail(satellite: modelData.satellites[0])
        .environment(modelData)
}
