//
//  CosmofyApp.swift
//  Cosmofy macOS
//
//  Created by Arryan Bhatnagar on 12/4/24.
//

import SwiftUI

@main
struct CosmofyMacApp: App {
    @StateObject private var viewModel = GQLViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .frame(minWidth: 900, minHeight: 600)
        }

        Settings {
            SettingsView()
        }
    }
}
