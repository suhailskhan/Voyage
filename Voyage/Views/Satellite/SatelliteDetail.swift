import SwiftUI
import CoreLocation
import MapKit

struct SatelliteDetail: View {
    @Binding var region: MapCameraPosition
    
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
        .toolbar {
            if (region.region?.center.latitude != self.satellite.location.coordinate.latitude && region.region?.center.longitude != self.satellite.location.coordinate.longitude) {
                Button {
                    region = MapCameraPosition.region(
                        MKCoordinateRegion(
                            center: satellite.location.coordinate,
                            span: MKCoordinateSpan(
                                latitudeDelta: 10.0,
                                longitudeDelta: 10.0
                            )
                        )
                    )
                } label: {
                    Text("Jump to location")
                }
            }
        }
    }
}

#Preview {
    struct Preview: View {
        @State var region = MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: 37.335378,
                    longitude: -121.879942
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: 0.05,
                    longitudeDelta: 0.05
                )
            )
        )
        
        let modelData = ModelData(dummy: true)
        
        var body: some View {
            return SatelliteDetail(region: $region, satellite: modelData.satellites[0])
        }
    }
    return Preview()
}
