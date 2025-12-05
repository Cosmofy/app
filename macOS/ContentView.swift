//
//  ContentView.swift
//  Cosmofy macOS
//
//  Created by Arryan Bhatnagar on 12/4/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: GQLViewModel

    var body: some View {
        TabView {
            MacIOTDView(viewModel: viewModel)
                .tabItem {
                    Label("Picture of the Day", image: "home-icon-2-small")
                }

            MacArticleView(articles: viewModel.articles)
                .tabItem {
                    Label("Articles", image: "home-icon-1-small")
                }

            MacNatureScopeDetailView(viewModel: viewModel)
                .tabItem {
                    Label("Nature Scope", image: "home-icon-4-small")
                }

            MacPlanetsView(viewModel: viewModel)
                .tabItem {
                    Label("Planets", image: "planets-icon-1-small")
                }

            MacSwiftView()
                .tabItem {
                    Label("Swift", image: "swift-small")
                }
        }
        .padding()
        .frame(minWidth: 900, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
    }
}
