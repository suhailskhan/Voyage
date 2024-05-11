import SwiftUI
import MapKit

struct SatelliteList: View {
    @Environment(ModelData.self) var modelData
    @Binding var region: MapCameraPosition
    
    var shownSatellites: [Satellite] {
        modelData.satellites
    }
    
    var body: some View {
        NavigationSplitView {
            List(shownSatellites) { satellite in
                NavigationLink {
                    SatelliteDetail(satellite: satellite)
                        .onAppear() {
                            region = MapCameraPosition.region(
                                MKCoordinateRegion(
                                    center: satellite.location.coordinate,
                                    span: MKCoordinateSpan(
                                        latitudeDelta: 10.0,
                                        longitudeDelta: 10.0
                                    )
                                )
                            )
                        }
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
        
        var body: some View {
            SatelliteList(region: $region)
        }
    }
    return Preview()
        .environment(ModelData(dummy: true))
}
