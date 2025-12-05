//
//  MacPlanetsView.swift
//  Cosmofy macOS
//
//  Created by Arryan Bhatnagar on 12/4/24.
//

import SwiftUI

struct MacPlanetsView: View {
    @ObservedObject var viewModel: GQLViewModel
    let planets: [Planet] = allPlanets

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let spacing: CGFloat = 16
                let horizontalPadding: CGFloat = 20
                let availableWidth = geometry.size.width - (horizontalPadding * 2)
                let availableHeight = geometry.size.height - (horizontalPadding * 2)
                let cardWidth = (availableWidth - (spacing * 3)) / 4
                let cardHeight = (availableHeight - spacing) / 2

                VStack(spacing: spacing) {
                    HStack(spacing: spacing) {
                        ForEach(planets.prefix(4)) { planet in
                            NavigationLink(destination: MacPlanetDetailView(planet: planet, viewModel: viewModel)) {
                                MacPlanetCardContent(planet: planet)
                            }
                            .buttonStyle(.plain)
                            .frame(width: cardWidth, height: cardHeight)
                        }
                    }
                    HStack(spacing: spacing) {
                        ForEach(planets.suffix(4)) { planet in
                            NavigationLink(destination: MacPlanetDetailView(planet: planet, viewModel: viewModel)) {
                                MacPlanetCardContent(planet: planet)
                            }
                            .buttonStyle(.plain)
                            .frame(width: cardWidth, height: cardHeight)
                        }
                    }
                }
                .padding(horizontalPadding)
            }
        }
    }
}

struct MacPlanetCardContent: View {
    let planet: Planet

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
                .frame(height: 16)

            HStack {
                Image(planet.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 90, height: 90)
                Spacer()
            }

            Spacer()

            Text(planet.name)
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(.primary)

            Text(planet.description)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .contentShape(RoundedRectangle(cornerRadius: 28))
    }
}

struct MacPlanetDetailView: View {
    let planet: Planet
    @ObservedObject var viewModel: GQLViewModel

    var body: some View {
        HStack(spacing: 0) {
            // Left side - Planet visual
            ZStack {
                Color.black
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                Image(planet.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 300, maxHeight: 300)
                    .shadow(color: planet.color.opacity(0.6), radius: 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()

            // Right side - Planet info
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("First Human Visual Observation")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                        Text(planet.visual)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }

                    // Description
                    Text(planet.expandedDescription)
                        .font(.body)
                        .fontDesign(.serif)
                        .italic()
                        .lineSpacing(4)
                        .textSelection(.enabled)
                        .padding(.top, 8)

                    // Planetary Facts
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 16) {
                            MacPropertyRow(title: "Natural Satellites", value: "\(planet.moons)", unit: planet.moons == 1 ? "moon" : "moons", color: planet.color)
                            MacPropertyRow(title: "Planetary Rings", value: "\(planet.rings)", unit: "rings", color: planet.color)
                        }
                        HStack(spacing: 16) {
                            MacPropertyRow(title: "Gravity", value: String(format: "%.2f", planet.gravity), unit: "m/s²", color: planet.color)
                            MacPropertyRow(title: "Escape Velocity", value: planet.escapeVelocity, unit: "km/h", color: planet.color)
                        }
                        MacPropertyRow(title: "Equatorial Radius", value: planet.radius, unit: "km", color: planet.color)
                        MacPropertyRow(title: "Mass", value: planet.mass, unit: "kg", color: planet.color)
                        MacPropertyRow(title: "Volume", value: planet.volume, unit: "km³", color: planet.color)
                    }
                    .padding(.top, 8)

                    // Atmosphere
                    if !planet.atmosphere.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Atmosphere")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(planet.atmosphere) { atmos in
                                        MacAtmosphereView(planet: planet, atmosphere: atmos)
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                    }

                    // Facts
                    if !planet.facts.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Did You Know?")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                            ForEach(planet.facts, id: \.self) { fact in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 12))
                                    Text(fact)
                                        .font(.system(size: 15, weight: .regular, design: .rounded))
                                        .textSelection(.enabled)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }

                    // Nature Scope for Earth
                    if planet.name == "Earth" {
                        NavigationLink(destination: MacNatureScopeDetailView(viewModel: viewModel)) {
                            Label("Nature Scope", systemImage: "globe.americas")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.green)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 8)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle(planet.name)
    }
}

struct MacPropertyRow: View {
    var title: String
    var value: String
    var unit: String
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                Text(unit)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MacAtmosphereView: View {
    var planet: Planet
    var atmosphere: Atmosphere

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(planet.color)

            VStack {
                HStack {
                    Spacer()
                    Text(atmosphere.molar)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.trailing, 4)
                .padding(.top, 4)

                HStack {
                    Text(atmosphere.formula)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.leading, 4)
                .padding(.bottom, 4)
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
