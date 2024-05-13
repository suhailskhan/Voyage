//
//  ContentView.swift
//  Voyage
//
//  Created by Suhail Khan on 2/20/24.
//

import SwiftUI
import MapKit
import BottomSheet

struct ContentView: View {
    @StateObject private var viewModel = SatelliteDataViewModel()
    @State private var isPresented = false
    @State private var selectedDetent: BottomSheet.PresentationDetent = .medium

    var body: some View {
        NavigationView {
            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
            )), interactionModes: [])
            .edgesIgnoringSafeArea(.all)
            .sheetPlus(
                isPresented: $isPresented,
                background: Color(UIColor.secondarySystemBackground)
                    .cornerRadius(12, corners: [.topLeft, .topRight]),
                onDrag: { translation in
                    print("Drag translation: \(translation)")
                },
                header: {
                    HeaderView()
                },
                main: {
                    MainContentView(viewModel: viewModel, selectedDetent: $selectedDetent)
                }
            )
            .onAppear {
                viewModel.fetchSatellites()
                isPresented = true
            }
            .navigationBarHidden(true)
        }
    }
}

struct HeaderView: View {
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Satellite Data")
                        .font(.title)
                        .fontWeight(.heavy)
                    Text("From NASA's TLE API")
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
                Spacer()
            }
            .padding(.top, 10)
            .padding(.bottom, 16)
            Divider()
                .frame(height: 1)
                .background(Color(UIColor.systemGray6))
        }
        .padding(.top, 8)
        .padding(.horizontal, 16)
    }
}

struct MainContentView: View {
    @ObservedObject var viewModel: SatelliteDataViewModel
    @Binding var selectedDetent: BottomSheet.PresentationDetent

    var body: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            List(viewModel.satellites) { satellite in
                VStack(alignment: .leading) {
                    Text(satellite.name).bold()
                    Text("ID: \(satellite.satelliteId)")
                    Text("Date: \(satellite.date)")
                    Text("Line 1: \(satellite.line1)")
                    Text("Line 2: \(satellite.line2)")
                }
                .padding(.vertical, 4)
            }
            .presentationDetentsPlus([.height(244), .fraction(0.4), .medium, .large], selection: $selectedDetent)
            .presentationDragIndicatorPlus(.visible)
        }
    }
}

#Preview {
    ContentView()
}
