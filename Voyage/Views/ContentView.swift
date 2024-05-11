import SwiftUI
import MapKit

struct ContentView: View {
    @Environment(ModelData.self) var modelData
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
    @State private var isPresented = true
    
    var shownSatellites: [Satellite] {
        modelData.satellites
    }
    
    let heights = Set([0.3, 0.5, 1.0]).map { PresentationDetent.fraction($0) }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $region)
            {
                ForEach(shownSatellites) { satellite in
                    Marker(satellite.name, coordinate: satellite.location.coordinate)
                }
            }
            .mapStyle(.hybrid(elevation: .realistic))
            .edgesIgnoringSafeArea(.all)
            .sheet(isPresented: $isPresented) {
                SatelliteList(region: $region)
                    .presentationDetents(Set(heights))
            }
            .animation(.default, value: region)
        }
    }
}

#Preview {
    ContentView()
        .environment(ModelData(dummy: true))
}
