import SwiftUI
import MapKit

struct SatelliteList: View {
    @Environment(ModelData.self) var modelData
    @Binding var searchText: String
    @Binding var region: MapCameraPosition
    @Binding var showVisibleOnly: Bool
    
    var shownSatellites: [Satellite] {
        var searchResults: [Satellite] {
            if searchText.isEmpty {
                return modelData.satellites
            } else {
                return modelData.satellites.filter { $0.name.contains(searchText) }
            }
        }
        
        if !showVisibleOnly {
            return searchResults
        }
        
        guard let regionCenter = region.region?.center,
              let regionSpan = region.region?.span else {
            return []
        }
        
        return searchResults.filter { satellite in
            let latitudeInRange = (regionCenter.latitude - regionSpan.latitudeDelta / 2) <= satellite.location.coordinate.latitude &&
            satellite.location.coordinate.latitude <= (regionCenter.latitude + regionSpan.latitudeDelta / 2)
            let longitudeInRange = (regionCenter.longitude - regionSpan.longitudeDelta / 2) <= satellite.location.coordinate.longitude &&
            satellite.location.coordinate.longitude <= (regionCenter.longitude + regionSpan.longitudeDelta / 2)
            return latitudeInRange && longitudeInRange
        }
    }
    
    var body: some View {
        NavigationView {
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
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .searchable(text: $searchText)
        .refreshable {
            modelData.reloadSatellites()
        }
    }
}

#Preview {
    struct Preview: View {
        @State var searchText = ""
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
            SatelliteList(searchText: $searchText, region: $region, showVisibleOnly: $showVisibleOnly)
        }
    }
    return Preview()
        .environment(ModelData(dummy: true))
}
