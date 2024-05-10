
import SwiftUI
import CoreLocation
import Foundation

struct SatelliteRow: View {
    var satellite: Satellite
    
    var body: some View {
        //        VStack(alignment: .leading) {
        VStack {
            HStack {
                Text(satellite.name).bold()
                Spacer()
            }
        }
        HStack {
            Text("Date:")
            Spacer()
            Text("\(satellite.epochDate, format: .dateTime.year().month().day())")
        }
        //        }
        HStack {
            Text("Location:")
            Spacer()
            Text("\(satellite.location.coordinate.latitude), \(satellite.location.coordinate.longitude)")
        }
        HStack {
            Text("Speed:")
            Spacer()
            Text("\(satellite.location.speed/1000, specifier: "%.2f") km/s")
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
