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

//#Preview {
//    SatelliteList(region: $r)
//        .environment(ModelData())
//        .environmentObject(MapModel())
//}
