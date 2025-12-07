//
//  PlanetsView.swift
//  Cosmofy
//
//  Created by Arryan Bhatnagar on 3/11/24.
//

import SwiftUI

struct PlanetsView: View {

    @ObservedObject var viewModel: GQLViewModel
    @State private var selectedTab: Tab?
    @Environment(\.colorScheme) private var scheme
    @State private var tabProgress: CGFloat = 0

    var innerPlanets: [GQLPlanet] {
        viewModel.planets.filter { planet in
            ["Mercury", "Venus", "Earth", "Mars"].contains(planet.name ?? "")
        }
    }

    var outerPlanets: [GQLPlanet] {
        viewModel.planets.filter { planet in
            ["Jupiter", "Saturn", "Uranus", "Neptune"].contains(planet.name ?? "")
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                CustomTabBar()
                    .padding(.top)

                GeometryReader {
                    let size = $0.size

                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 0) {
                            ScrollView(.vertical) {
                                ForEach(innerPlanets, id: \.name) { planet in
                                    PlanetBlock(planet: planet, viewModel: viewModel)
                                }
                            }
                            .listStyle(PlainListStyle())
                            .id(Tab.inner)
                            .containerRelativeFrame(.horizontal)

                            ScrollView(.vertical) {
                                ForEach(outerPlanets, id: \.name) { planet in
                                    PlanetBlock(planet: planet, viewModel: viewModel)
                                }
                            }
                            .id(Tab.outer)
                            .containerRelativeFrame(.horizontal)

                            ScrollView(.vertical) {
                                VStack {
                                    Image("solar-system")
                                        .resizable()
                                        .frame(width: 45, height: 45)
                                        .padding(.bottom, 8)

                                    Text("Coming Soon!")
                                        .font(.system(size: 24, weight: .semibold, design: .rounded))

                                    Text("Get ready to explore the solar system like never before with our upcoming 3D and AR model for the whole solar system. Stay tuned!")
                                        .font(.system(size: 18, design: .rounded))
                                        .foregroundStyle(.secondary)
                                        .padding([.leading, .trailing])
                                        .padding(.top, 8)
                                    Text("- July 2026 -")
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(.blue)
                                        .padding()
                                }
                                .padding()
                                .padding(.top, 32)
                            }
                            .id(Tab.solar)
                            .containerRelativeFrame(.horizontal)
                        }
                        .scrollTargetLayout()
                        .offsetX { value in
                            let progress = -value / (size.width * CGFloat(Tab.allCases.count - 1))
                            tabProgress = max(min(progress, 1), 0)
                        }
                    }
                    .scrollPosition(id: $selectedTab)
                    .scrollIndicators(.hidden)
                    .scrollTargetBehavior(.paging)
                    .scrollClipDisabled()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle("Planets")
        }
    }

    @ViewBuilder
    func CustomTabBar() -> some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                HStack(spacing: 10) {
                    Image(tab.image)
                        .resizable()
                        .frame(width: 25, height: 25)
                    Text(tab.rawValue)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .contentShape(.capsule)
                .onTapGesture {
                    withAnimation(.snappy) {
                        selectedTab = tab
                    }
                }
            }
        }
        .tabMask(tabProgress)
        .background {
            GeometryReader {
                let size = $0.size
                let capsuleWidth = size.width / CGFloat(Tab.allCases.count)

                Capsule()
                    .fill(scheme == .dark ? .black : .gray.opacity(0.1))
                    .frame(width: capsuleWidth)
                    .offset(x: tabProgress * (size.width - capsuleWidth))
            }
        }
        .background(.gray.opacity(0.1), in: .capsule)
        .padding(.horizontal, 15)
    }
}

struct PlanetBlock: View {
    var planet: GQLPlanet
    @ObservedObject var viewModel: GQLViewModel

    var body: some View {
        NavigationLink(destination: PlanetDetailView(planet: planet, viewModel: viewModel)) {
            HStack(spacing: 16) {
                Image(planetImageName(for: planet.name ?? ""))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .padding(.leading, 4)

                VStack {
                    HStack {
                        Text(planet.name ?? "Unknown")
                            .font(.title3)
                            .fontDesign(.rounded)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    HStack {
                        Text(planet.description ?? "")
                            .fontDesign(.rounded)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                }

                Image(systemName: "chevron.right")
                    .padding()
            }
            .padding()
        }
    }

    func planetImageName(for name: String) -> String {
        switch name.lowercased() {
        case "mercury": return "smiling-mercury"
        case "venus": return "smiling-venus"
        case "earth": return "smiling-earth"
        case "mars": return "smiling-mars"
        case "jupiter": return "smiling-jupiter"
        case "saturn": return "smiling-saturn"
        case "uranus": return "smiling-uranus"
        case "neptune": return "smiling-neptune"
        default: return "smiling-earth"
        }
    }
}

