#if swift(>=5.9)
//
//  PlanetView.swift
//  Cosmofy
//
//  Created by Arryan Bhatnagar on 2/9/24.
//

import SwiftUI
import SceneKit
import Charts

struct AnimatedPlanetTemp: Identifiable {
    let id: String
    let name: String
    let temperature: Int
    var isAnimated: Bool = false
}

struct PlanetDetailView: View {

    var planet: GQLPlanet
    @ObservedObject var viewModel: GQLViewModel
    @State private var isAnimated: Bool = false
    @State private var isPresented = false
    @Environment(\.colorScheme) var colorScheme
    @State var loadedChart = false
    @State private var animatedPlanets: [AnimatedPlanetTemp] = []

    var planetColor: Color {
        switch planet.name?.lowercased() {
        case "mercury": return .colorMercury
        case "venus": return .colorVenus
        case "earth": return .colorEarth
        case "mars": return .colorMars
        case "jupiter": return .colorJupiter
        case "saturn": return .colorSaturn
        case "uranus": return .colorUranus
        case "neptune": return .colorNeptune
        default: return .blue
        }
    }

    var planetOrder: String {
        switch planet.name?.lowercased() {
        case "mercury": return "1st"
        case "venus": return "2nd"
        case "earth": return "3rd"
        case "mars": return "4th"
        case "jupiter": return "5th"
        case "saturn": return "6th"
        case "uranus": return "7th"
        case "neptune": return "8th"
        default: return ""
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {

                // MARK: Section 1 - Header
                HStack {
                    VStack {
                        HStack {
                            Text("First Human Visual Observation")
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        HStack {
                            Text(planet.visual ?? "Unknown")
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    Spacer()
                    ZStack {
                        Circle()
                            .stroke(planetColor, lineWidth: 4)
                        Text(planetOrder)
                            .fontDesign(.rounded)
                            .font(.headline)
                    }
                    .frame(width: 44, height: 44)
                }
                .padding()

                // MARK: 3D Model
                planetModel
                    .padding(.horizontal, 24)

                // MARK: Description
                HStack {
                    Text(planet.expandedDescription ?? "")
                        .fontDesign(.serif)
                        .italic()
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                        .padding(.top)
                    Spacer()
                }
                .padding()

                // Nature Scope for Earth
                if planet.name == "Earth" {
                    NavView(
                        view: NatureScope(viewModel: viewModel),
                        imageName: "home-icon-4",
                        title: "Nature Scope",
                        subtitle: "View natural events and disasters around the globe"
                    )
                }

                // MARK: Planetary Facts Section
                VStack {
                    HStack {
                        Text("planetary facts")
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    Divider()
                }
                .padding(.horizontal, 32)
                .padding(.top)

                // Basic Properties
                HStack {
                    PlanetPropertyView(title: "Natural Satellites", value: String(planet.moons ?? 0), unit: "moons", color: planetColor)
                    PlanetPropertyView(title: "Planetary Rings", value: String(planet.rings ?? 0), unit: "rings", color: planetColor)
                }
                .padding(.horizontal, 32)
                .padding(.top, 16)

                HStack {
                    PlanetPropertyView(title: "Gravity (Equatorial)", value: formatDouble(planet.gravityEquatorial), unit: "m/s²", color: planetColor)
                    PlanetPropertyView(title: "Escape Velocity", value: formatDouble(planet.escapeVelocity), unit: "km/s", color: planetColor)
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)

                PlanetPropertyView(title: "Equatorial Radius", value: formatScientific(planet.radiusEquatorial), unit: "km", color: planetColor)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)

                PlanetPropertyView(title: "Mass", value: formatScientific(planet.mass), unit: "kg", color: planetColor)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)

                PlanetPropertyView(title: "Volume", value: formatScientific(planet.volume), unit: "km³", color: planetColor)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)

                // MARK: Additional Properties from API
                VStack {
                    HStack {
                        Text("orbital parameters")
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    Divider()
                }
                .padding(.horizontal, 32)
                .padding(.top, 24)

                HStack {
                    PlanetPropertyView(title: "Orbital Velocity", value: formatDouble(planet.orbitalVelocity), unit: "km/s", color: planetColor)
                    PlanetPropertyView(title: "Orbital Inclination", value: formatDouble(planet.orbitalInclination), unit: "°", color: planetColor)
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)

                HStack {
                    PlanetPropertyView(title: "Orbit Period", value: formatDouble(planet.siderealOrbitPeriodY), unit: "years", color: planetColor)
                    PlanetPropertyView(title: "Day Length", value: formatDouble(planet.solarDayLength), unit: "hours", color: planetColor)
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)

                HStack {
                    PlanetPropertyView(title: "Axial Tilt", value: formatDouble(planet.obliquityToOrbit), unit: "°", color: planetColor)
                    PlanetPropertyView(title: "Rotation Period", value: formatDouble(planet.siderealRotationPeriod), unit: "hours", color: planetColor)
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)

                // MARK: Physical Properties
                VStack {
                    HStack {
                        Text("physical properties")
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    Divider()
                }
                .padding(.horizontal, 32)
                .padding(.top, 24)

                HStack {
                    PlanetPropertyView(title: "Density", value: formatDouble(planet.density), unit: "g/cm³", color: planetColor)
                    PlanetPropertyView(title: "Flattening", value: formatDouble(planet.flattening), unit: "", color: planetColor)
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)

                HStack {
                    PlanetPropertyView(title: "Surface Pressure", value: formatDouble(planet.pressure), unit: "bar", color: planetColor)
                    PlanetPropertyView(title: "Albedo", value: formatDouble(planet.albedo), unit: "", color: planetColor)
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)

                if let temp = planet.temperature {
                    PlanetPropertyView(title: "Temperature", value: "\(temp)", unit: "K", color: planetColor)
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                }

                // MARK: Atmosphere
                if let atmosphere = planet.atmosphere, !atmosphere.isEmpty {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Atmosphere")
                                .fontDesign(.rounded)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(atmosphere) { atmos in
                                        AtmosphereView(color: planetColor, atmosphere: atmos)
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 16)

                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(atmosphere) { component in
                            if let percentage = component.percentage, percentage > 0 {
                                HStack {
                                    Text(component.name ?? component.formula ?? "")
                                        .font(.subheadline)
                                        .fontDesign(.rounded)
                                    Spacer()
                                    Text(String(format: "%.2f%%", percentage))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                }

                // MARK: Temperature Chart
                if let temp = planet.temperature {
                    temperatureSection(temperature: temp - 273)
                }

                // MARK: Facts
                if let facts = planet.facts, !facts.isEmpty {
                    VStack {
                        HStack {
                            Text("did you know?")
                                .textCase(.uppercase)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        Divider()
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 24)

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(facts, id: \.self) { fact in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                    .padding(.top, 4)
                                Text(fact)
                                    .font(.subheadline)
                                    .fontDesign(.rounded)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }

            }
            .navigationTitle(planet.name ?? "Planet")
            .navigationBarItems(
                trailing: ShareLink(item: URL(string: "https://apps.apple.com/app/cosmofy/id6450969556")!, preview: SharePreview("Cosmofy on the Apple App Store", image: Image("iconApp")))
                    .foregroundStyle(planetColor)
            )
            .onAppear {
                if animatedPlanets.isEmpty {
                    animatedPlanets = viewModel.planets.compactMap { p in
                        guard let name = p.name, let temp = p.temperature else { return nil }
                        return AnimatedPlanetTemp(id: name, name: name, temperature: temp - 273, isAnimated: false)
                    }
                }
            }
        }
    }

    // MARK: - 3D Model
    private var planetModel: some View {
        ZStack {
            SceneView(
                scene: createPlanetScene(planetName: planet.name?.lowercased() ?? "earth", isFullScreen: false, platform: nil).scene,
                options: [.allowsCameraControl, .autoenablesDefaultLighting]
            )
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        self.isPresented.toggle()
                    }) {
                        HStack {
                            Image(systemName: "arrow.down.left.and.arrow.up.right")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.white.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding()
                    }
                    .padding(4)
                    .fullScreenCover(isPresented: $isPresented) {
                        FullScreenPlanetView(planetName: planet.name ?? "Earth", color: planetColor)
                    }
                }
                Spacer()
            }

            VStack {
                Spacer()
                HStack {
                    Text(" SceneKit")
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding([.bottom, .leading], 20)
                    Spacer()
                }
            }
            Spacer()
        }
    }

    // MARK: - Temperature Section
    @ViewBuilder
    private func temperatureSection(temperature: Int) -> some View {
        HStack {
            Text("Average Temperatures of Planets")
                .fontDesign(.rounded)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.top, 24)
        .padding(.horizontal, 32)

        ZStack {
            GeometryReader { geometry in
                Chart(animatedPlanets) { p in
                    BarMark(
                        x: .value("Temperature", p.isAnimated ? p.temperature : 0),
                        y: .value("Name", p.name)
                    )
                    .foregroundStyle(planet.name == p.name ? planetColorFor(p.name).gradient : planetColorFor(p.name).opacity(0.2).gradient)
                }
                .foregroundStyle(.black)
                .fontDesign(.rounded)
                .chartXScale(domain: -300...500)
                .padding(.horizontal)
                .onChange(of: geometry.frame(in: .global).minY) {
                    if geometry.frame(in: .global).maxY < 900 {
                        loadedChart = true
                    }
                }
                .onChange(of: loadedChart) { oldValue, newValue in
                    if loadedChart == true {
                        animateChart()
                    }
                }
            }
            .frame(height: 400)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Gauge(value: Float(temperature + 273), in: 0...1000) {
                            Text("K")
                        } currentValueLabel: {
                            Text("\(temperature + 273)")
                                .font(.headline)
                        }
                        .background(.BETRAY)
                        .tint(Gradient(colors: [planetColor.opacity(0.7), planetColor, planetColor.opacity(0.75)]))
                        .gaugeStyle(AccessoryCircularGaugeStyle())
                        .padding(.horizontal)

                        Gauge(value: Float(temperature), in: -280...600) {
                            Text("°C")
                        } currentValueLabel: {
                            Text("\(temperature)")
                                .font(.headline)
                        }
                        .background(.BETRAY)
                        .tint(Gradient(colors: [planetColor.opacity(0.7), planetColor, planetColor.opacity(0.75)]))
                        .gaugeStyle(AccessoryCircularGaugeStyle())
                        .padding([.bottom, .horizontal])
                    }
                }
            }
            .padding()
        }
        .padding(.horizontal)
        .padding(.top, 8)

        HStack {
            Text("Planets farther from the Sun have lower temperatures, highlighting the impact of solar distance on planetary climates.")
                .fontDesign(.rounded)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.top, 8)
    }

    private func animateChart() {
        guard !isAnimated else { return }
        isAnimated = true

        for index in animatedPlanets.indices {
            let delay = Double(index) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.smooth) {
                    animatedPlanets[index].isAnimated = true
                }
            }
        }
    }

    // MARK: - Helpers
    func formatDouble(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        if value == 0 { return "0" }
        if abs(value) >= 1000 || abs(value) < 0.01 {
            return String(format: "%.2e", value)
        }
        return String(format: "%.2f", value)
    }

    func formatScientific(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        if value == 0 { return "0" }
        return String(format: "%.3e", value)
    }

    func planetColorFor(_ name: String?) -> Color {
        switch name?.lowercased() {
        case "mercury": return .colorMercury
        case "venus": return .colorVenus
        case "earth": return .colorEarth
        case "mars": return .colorMars
        case "jupiter": return .colorJupiter
        case "saturn": return .colorSaturn
        case "uranus": return .colorUranus
        case "neptune": return .colorNeptune
        default: return .blue
        }
    }
}

// MARK: - Supporting Views

struct PlanetPropertyView: View {
    var title: String
    var value: String
    var unit: String
    var color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontDesign(.rounded)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                HStack(alignment: .firstTextBaseline) {
                    Text(value).foregroundStyle(.BETRAYED)
                        .font(.title2)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)

                    if unit == "moons" && value == "1" {
                        Text("moon")
                            .fontDesign(.rounded)
                            .fontWeight(.medium)
                            .foregroundStyle(color)
                    } else {
                        Text(unit)
                            .fontDesign(.rounded)
                            .fontWeight(.medium)
                            .foregroundStyle(color)
                    }
                }
            }
            Spacer()
        }
    }
}

struct AtmosphereView: View {
    var color: Color
    var atmosphere: GQLComponent

    private var boxWidth: CGFloat {
        let formulaLength = (atmosphere.formula ?? "").count
        if formulaLength <= 2 {
            return 42
        } else if formulaLength <= 4 {
            return 52
        } else {
            return 62
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(color.gradient)

            VStack {
                HStack {
                    Spacer()
                    Text("\(atmosphere.molar ?? 0)")
                        .font(.caption2)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .padding(.trailing, 3)
                .padding(.top, 3)

                HStack {
                    Text(atmosphere.formula ?? "")
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.leading, 4)
                .padding(.bottom, 3)
            }
        }
        .frame(width: boxWidth, height: 42)
        .cornerRadius(8)
    }
}

struct FullScreenPlanetView: View {
    let planetName: String
    let color: Color
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            SceneView(
                scene: createPlanetScene(planetName: planetName.lowercased(), isFullScreen: true, platform: nil).scene,
                options: [.allowsCameraControl, .autoenablesDefaultLighting]
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}
#endif
