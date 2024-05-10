//
//  VoyageApp.swift
//  Voyage
//
//  Created by Suhail Khan on 2/20/24.
//

import SwiftUI

@main
struct VoyageApp: App {
    @State private var modelData = ModelData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(modelData)
        }
    }
}
