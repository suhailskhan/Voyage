import SwiftUI
import BottomSheet
import MapKit

struct ContentView: View {
    @Environment(ModelData.self) var modelData
    @State var searchText = ""
    @State var region = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 37.335378,
                longitude: -121.879942
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 100,
                longitudeDelta: 100
            )
        )
    )
    @State var userMapDragPosition = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 37.335378,
            longitude: -121.879942
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 100,
            longitudeDelta: 100
        )
    )
    @State var showVisibleOnly = false
    @State var bottomSheetPosition: BottomSheetPosition = .relative(0.4)
    
    var shownSatellites: [Satellite] {
        var searchResults: [Satellite] {
            if searchText.isEmpty {
                return modelData.satellites
            } else {
                return modelData.satellites.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        if !showVisibleOnly {
            return searchResults
        }
        
        let regionCenter = userMapDragPosition.center
        let regionSpan = userMapDragPosition.span
        
        return searchResults.filter { satellite in
            let latitudeInRange = (regionCenter.latitude - regionSpan.latitudeDelta / 2) <= satellite.location.coordinate.latitude &&
            satellite.location.coordinate.latitude <= (regionCenter.latitude + regionSpan.latitudeDelta / 2)
            let longitudeInRange = (regionCenter.longitude - regionSpan.longitudeDelta / 2) <= satellite.location.coordinate.longitude &&
            satellite.location.coordinate.longitude <= (regionCenter.longitude + regionSpan.longitudeDelta / 2)
            return latitudeInRange && longitudeInRange
        }
    }
    
    let heights = Set([0.3, 0.5, 1.0]).map { PresentationDetent.fraction($0) }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $region) {
                ForEach(shownSatellites) { satellite in
                    Marker(satellite.name, coordinate: satellite.location.coordinate)
                }
            }
            .mapStyle(.hybrid(elevation: .realistic))
            .edgesIgnoringSafeArea(.all)
            .onMapCameraChange { context in
                userMapDragPosition = context.region
            }
            .bottomSheet(
                bottomSheetPosition: $bottomSheetPosition,
                switchablePositions: [
                    .relativeBottom(0.125),
                    .relative(0.4),
                    .relativeTop(0.975)
                ],
                content: {
                    SatelliteList(searchText: $searchText, region: $region, userMapDragPosition: $userMapDragPosition, showVisibleOnly: $showVisibleOnly)
                }
            )
            .animation(.default, value: region)
        }
    }
}

#Preview {
    ContentView()
        .environment(ModelData(dummy: true))
}
