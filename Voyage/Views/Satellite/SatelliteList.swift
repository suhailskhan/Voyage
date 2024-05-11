import SwiftUI
import MapKit

struct SatelliteList: View {
    @Environment(ModelData.self) var modelData
    @Binding var region: MapCameraPosition
    @Binding var showVisibleOnly: Bool
    
    var shownSatellites: [Satellite] {
        if !showVisibleOnly {
            return modelData.satellites
        }
        
        guard let regionCenter = region.region?.center,
              let regionSpan = region.region?.span else {
            return []
        }
        
        return modelData.satellites.filter { satellite in
            let latitudeInRange = (regionCenter.latitude - regionSpan.latitudeDelta / 2) <= satellite.location.coordinate.latitude &&
            satellite.location.coordinate.latitude <= (regionCenter.latitude + regionSpan.latitudeDelta / 2)
            let longitudeInRange = (regionCenter.longitude - regionSpan.longitudeDelta / 2) <= satellite.location.coordinate.longitude &&
            satellite.location.coordinate.longitude <= (regionCenter.longitude + regionSpan.longitudeDelta / 2)
            return latitudeInRange && longitudeInRange
        }
    }
    
    var body: some View {
        NavigationSplitView {
            List(shownSatellites) { satellite in
                NavigationLink {
                    SatelliteDetail(region: $region, satellite: satellite)
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
            .toolbar {
                Button {
                    showVisibleOnly.toggle()
                    return
                } label: {
                    if showVisibleOnly {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    } else {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
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
        @State var showVisibleOnly = false
        
        var body: some View {
            SatelliteList(region: $region, showVisibleOnly: $showVisibleOnly)
        }
    }
    return Preview()
        .environment(ModelData(dummy: true))
}
