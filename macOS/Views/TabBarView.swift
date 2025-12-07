//
//  TabBarView.swift
//  Cosmofy
//
//  Created by Arryan Bhatnagar on 3/9/24.
//

import SwiftUI

struct TabBarView: View {

    @ObservedObject var gqlViewModel: GQLViewModel

    var body: some View {
        TabView {
            Home(viewModel: gqlViewModel)
                .tabItem {
                    Label("Home", image: "tab-bar-home")
                }

            PlanetsView(viewModel: gqlViewModel)
                .tabItem {
                    Label("Planets", image: "tab-bar-planets")
                }

            SwiftView()
                .tabItem {
                    Label("Swift", image: "tab-bar-swift")
                }

            Profile()
                .tabItem {
                    Label("Profile", image: "tab-bar-profile")
                }
        }
        .tint(.primary)
    }


}

struct TabBarKids: View {
    @ObservedObject var gqlViewModel: GQLViewModel

    var body: some View {
        TabView {
            Learn(gqlViewModel: gqlViewModel)
                .tabItem {
                    Image(systemName: "house")
                    Text("Learn")
                }
                .tag(0)
            
            Profile()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(1)
        }
        .tint(.primary)
 
    }
}


