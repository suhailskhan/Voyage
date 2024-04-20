import SwiftUI
import MapKit

struct ContentView: View {
    // Mock satellite data
    @State var satelliteData: [SatelliteData] = [
        SatelliteData(name: "Hubble", origin: "Earth", location: "Low Earth Orbit", speed: 7.66),
        SatelliteData(name: "ISS", origin: "Earth", location: "Low Earth Orbit", speed: 7.66),
        SatelliteData(name: "GPS IIIA-3", origin: "Earth", location: "Medium Earth Orbit", speed: 3.00)
    ]

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Map()
                
                DraggableSatelliteDataList(satelliteData: $satelliteData)
            }
            .navigationBarHidden(true)
        }
    }
}

struct SatelliteData: Identifiable {
    let id = UUID()
    var name: String
    var origin: String
    var location: String
    var speed: Double
}

struct DraggableSatelliteDataList: View {
    @Binding var satelliteData: [SatelliteData]

    var body: some View {
        VStack {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray)
                .padding(5)
            List {
                ForEach(satelliteData) { data in
                    SatelliteDataRow(data: data)
                }
            }
        }
        .background(BlurView(style: .systemMaterial))
        .cornerRadius(20)
        .frame(height: 500)
        .offset(y: 50)
    }
}

struct SatelliteDataRow: View {
    var data: SatelliteData
    
    var body: some View {
        NavigationLink(destination: SatelliteDetailView(satellite: data)) {
            VStack(alignment: .leading) {
                Text(data.name).bold()
                HStack {
                    Text("Origin:")
                    Spacer()
                    Text(data.origin)
                }
                HStack {
                    Text("Location:")
                    Spacer()
                    Text(data.location)
                }
                HStack {
                    Text("Speed:")
                    Spacer()
                    Text("\(data.speed, specifier: "%.2f") km/s")
                }
            }
            .padding(.vertical, 4)
        }
    }
}


struct SatelliteDetailView: View {
    var satellite: SatelliteData
    var tleData: [String] = ["Satellite Name: ISS (ZARYA)", "Origin: 25544U", "Speed: 15.48966399293174 km/h", "Location: Latitude 51.6457°, Longitude 93.6940°"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(satellite.name).font(.title).bold()

                Text("TLE Data").font(.headline)
                ForEach(tleData, id: \.self) { line in
                    Text(line)
                }

                MapView(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
                    .frame(height: 200)
            }
            .padding()
        }
        .navigationBarTitle(Text(satellite.name), displayMode: .inline)
    }
}

struct MapView: UIViewRepresentable {
    var coordinate: CLLocationCoordinate2D

    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        uiView.setRegion(region, animated: true)
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
