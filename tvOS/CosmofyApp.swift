//
//  Cosmofy_for_TVApp.swift
//  Cosmofy for TV
//
//  Created by Arryan Bhatnagar on 6/30/24.
//

import SwiftUI
import MapKit

@main
struct CosmofyApp: App {
    var body: some Scene {
        WindowGroup {
            TabBarView()
        }
    }
}


struct TabBarView: View {

    @StateObject private var gqlViewModel = GQLViewModel()

    var body: some View {
        TabView {

            Home(viewModel: gqlViewModel)
                .tabItem {
                    Label("Home", image: "tab-bar-home")
                }

            PlanetsView()
                .tabItem {
                    Label("Planets", image: "tab-bar-planets")
                }

            SwiftView()
                .tabItem {
                    Label("Swift", image: "tab-bar-swift")
                }

            RNNMaybach(viewModel: gqlViewModel, complete: $gqlViewModel.eventsLoaded, failed: $gqlViewModel.eventsFailed)
                .tabItem {
                    Label("Nature Scope", image: "tab-bar-naturescope")
                }

        }
        .tint(.primary)
    }
}

#Preview {
    TabBarView()
}
