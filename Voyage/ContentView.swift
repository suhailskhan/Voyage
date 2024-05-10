import SwiftUI
import MapKit
import SGPKit

struct ContentView: View {
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
    @State private var isPresented = true
    
    let heights = Set([0.3, 0.5, 1.0]).map { PresentationDetent.fraction($0) }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $region)
                .edgesIgnoringSafeArea(.all)
                .sheet(isPresented: $isPresented) {
                    SatelliteList()
                        .presentationDetents(Set(heights))
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(ModelData())
}
