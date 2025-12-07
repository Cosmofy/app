//
//  MacPlanetsView.swift
//  Cosmofy macOS
//
//  Planets view for macOS with SceneKit 3D
//

import SwiftUI
import SceneKit
import Charts

struct PlanetsView: View {

    @ObservedObject var viewModel: GQLViewModel
    @Environment(\.colorScheme) private var scheme

    let innerPlanets = ["Mercury", "Venus", "Earth", "Mars"]
    let outerPlanets = ["Jupiter", "Saturn", "Uranus", "Neptune"]

    var body: some View {
        NavigationStack {
            ScrollView {
                HStack(alignment: .top, spacing: 24) {
                    // Left column - Inner planets
                    VStack(spacing: 0) {
                        HStack {
                            Text("Inner Planets")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.bottom, 8)

                        ForEach(viewModel.planets.filter { innerPlanets.contains($0.name ?? "") }, id: \.name) { planet in
                            PlanetBlock(planet: planet, viewModel: viewModel)
                        }
                    }

                    // Right column - Outer planets
                    VStack(spacing: 0) {
                        HStack {
                            Text("Outer Planets")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.bottom, 8)

                        ForEach(viewModel.planets.filter { outerPlanets.contains($0.name ?? "") }, id: \.name) { planet in
                            PlanetBlock(planet: planet, viewModel: viewModel)
                        }
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle("Planets")
        }
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
                    .frame(width: 60, height: 60)
                    .padding(.leading, 4)

                VStack {
                    HStack {
                        Text(planet.name ?? "Unknown")
                            .font(.title2)
                            .fontDesign(.rounded)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    HStack {
                        Text(planet.description ?? "")
                            .fontDesign(.rounded)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .padding(.bottom, 8)
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

// MARK: - Planet Detail View

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
    @State private var planetScene: SCNScene?

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
        HStack(alignment: .top, spacing: 0) {
            // MARK: Left side - Big 3D Planet
            VStack {
                planetModel
                    .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity)

            // MARK: Right side - Scrollable data
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Planet name and order
                    HStack {
                        Text(planet.name ?? "Planet")
                            .font(.system(size: 36))
                            .fontWeight(.bold)
                            .fontDesign(.rounded)

                        Spacer()

                        ZStack {
                            Circle()
                                .stroke(planetColor, lineWidth: 3)
                            Text(planetOrder)
                                .fontDesign(.rounded)
                                .font(.headline)
                        }
                        .frame(width: 44, height: 44)
                    }

                    // Visual observation
                    VStack(alignment: .leading, spacing: 4) {
                        Text("First Human Visual Observation")
                            .font(.body)
                            .fontDesign(.rounded)
                            .foregroundColor(.secondary)
                        Text(planet.visual ?? "Unknown")
                            .font(.body)
                            .fontDesign(.rounded)
                            .foregroundColor(.secondary)
                    }

                    // Description
                    Text(planet.expandedDescription ?? "")
                        .fontDesign(.serif)
                        .italic()
                        .font(.title3)
                        .multilineTextAlignment(.leading)

                    // Nature Scope for Earth
                    if planet.name == "Earth" {
                        NavView(
                            view: NatureScope(viewModel: viewModel),
                            imageName: "home-icon-4",
                            title: "Nature Scope",
                            subtitle: "View natural events and disasters around the globe"
                        )
                        .padding(.horizontal, -16)
                    }

                    // MARK: Planetary Facts
                    sectionHeader("planetary facts")

                    HStack {
                        PlanetPropertyView(title: "Natural Satellites", value: String(planet.moons ?? 0), unit: "moons", color: planetColor)
                        PlanetPropertyView(title: "Planetary Rings", value: String(planet.rings ?? 0), unit: "rings", color: planetColor)
                    }

                    HStack {
                        PlanetPropertyView(title: "Gravity (Equatorial)", value: formatDouble(planet.gravityEquatorial), unit: "m/s²", color: planetColor)
                        PlanetPropertyView(title: "Escape Velocity", value: formatDouble(planet.escapeVelocity), unit: "km/s", color: planetColor)
                    }

                    PlanetPropertyView(title: "Equatorial Radius", value: formatScientific(planet.radiusEquatorial), unit: "km", color: planetColor)
                    PlanetPropertyView(title: "Mass", value: formatScientific(planet.mass), unit: "kg", color: planetColor)
                    PlanetPropertyView(title: "Volume", value: formatScientific(planet.volume), unit: "km³", color: planetColor)

                    // MARK: Orbital Parameters
                    sectionHeader("orbital parameters")

                    HStack {
                        PlanetPropertyView(title: "Orbital Velocity", value: formatDouble(planet.orbitalVelocity), unit: "km/s", color: planetColor)
                        PlanetPropertyView(title: "Orbital Inclination", value: formatDouble(planet.orbitalInclination), unit: "°", color: planetColor)
                    }

                    HStack {
                        PlanetPropertyView(title: "Orbit Period", value: formatDouble(planet.siderealOrbitPeriodY), unit: "years", color: planetColor)
                        PlanetPropertyView(title: "Day Length", value: formatDouble(planet.solarDayLength), unit: "hours", color: planetColor)
                    }

                    HStack {
                        PlanetPropertyView(title: "Axial Tilt", value: formatDouble(planet.obliquityToOrbit), unit: "°", color: planetColor)
                        PlanetPropertyView(title: "Rotation Period", value: formatDouble(planet.siderealRotationPeriod), unit: "hours", color: planetColor)
                    }

                    // MARK: Physical Properties
                    sectionHeader("physical properties")

                    HStack {
                        PlanetPropertyView(title: "Density", value: formatDouble(planet.density), unit: "g/cm³", color: planetColor)
                        PlanetPropertyView(title: "Flattening", value: formatDouble(planet.flattening), unit: "", color: planetColor)
                    }

                    HStack {
                        PlanetPropertyView(title: "Surface Pressure", value: formatDouble(planet.pressure), unit: "bar", color: planetColor)
                        PlanetPropertyView(title: "Albedo", value: formatDouble(planet.albedo), unit: "", color: planetColor)
                    }

                    if let temp = planet.temperature {
                        PlanetPropertyView(title: "Temperature", value: "\(temp)", unit: "K", color: planetColor)
                    }

                    // MARK: Atmosphere
                    if let atmosphere = planet.atmosphere, !atmosphere.isEmpty {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Atmosphere")
                                    .font(.title3)
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

                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(atmosphere) { component in
                                if let percentage = component.percentage, percentage > 0 {
                                    HStack {
                                        Text(component.name ?? component.formula ?? "")
                                            .font(.body)
                                            .fontDesign(.rounded)
                                        Spacer()
                                        Text(String(format: "%.2f%%", percentage))
                                            .font(.body)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }

                    // MARK: Temperature Chart
                    if let temp = planet.temperature {
                        temperatureSection(temperature: temp - 273)
                    }

                    // MARK: Facts
                    if let facts = planet.facts, !facts.isEmpty {
                        sectionHeader("did you know?")

                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(facts, id: \.self) { fact in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.body)
                                        .padding(.top, 4)
                                    Text(fact)
                                        .font(.title3)
                                        .fontDesign(.rounded)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                        .padding(.bottom, 32)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(planet.name ?? "Planet")
        .onAppear {
            if animatedPlanets.isEmpty {
                animatedPlanets = viewModel.planets.compactMap { p in
                    guard let name = p.name, let temp = p.temperature else { return nil }
                    return AnimatedPlanetTemp(id: name, name: name, temperature: temp - 273, isAnimated: false)
                }
            }
        }
    }

    // Section header helper
    private func sectionHeader(_ title: String) -> some View {
        VStack {
            HStack {
                Text(title)
                    .font(.title3)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            Divider()
        }
        .padding(.top, 8)
    }

    // MARK: - 3D Model
    private var planetModel: some View {
        ZStack {
            if let scene = planetScene {
                SceneView(
                    scene: scene,
                    options: [.allowsCameraControl, .autoenablesDefaultLighting]
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }

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
                    .buttonStyle(.plain)
                    .padding(4)
                    .sheet(isPresented: $isPresented) {
                        FullScreenPlanetView(planetName: planet.name ?? "Earth", color: planetColor)
                    }
                }
                Spacer()
            }

            VStack {
                Spacer()
                HStack {
                    Image(systemName: "apple.logo")
                        .font(.title3)
                        .foregroundColor(.white)
                    Text("SceneKit")
                        .font(.title3)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding([.bottom, .leading], 20)
            }
        }
        .padding()
        .onAppear {
            if planetScene == nil {
                planetScene = createPlanetScene(planetName: planet.name?.lowercased() ?? "earth", isFullScreen: false, platform: nil).scene
            }
        }
    }

    // MARK: - Temperature Section
    @ViewBuilder
    private func temperatureSection(temperature: Int) -> some View {
        HStack {
            Text("Average Temperatures of Planets")
                .font(.title3)
                .fontDesign(.rounded)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.top, 16)

        ZStack {
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
            .frame(height: 400)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    animateChart()
                }
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Gauge(value: Float(temperature + 273), in: 0...1000) {
                            Text("K")
                        } currentValueLabel: {
                            Text("\(temperature + 273)")
                                .font(.title3)
                        }
                        .tint(Gradient(colors: [planetColor.opacity(0.7), planetColor, planetColor.opacity(0.75)]))
                        .gaugeStyle(AccessoryCircularGaugeStyle())
                        .scaleEffect(1.2)

                        Gauge(value: Float(temperature), in: -280...600) {
                            Text("°C")
                        } currentValueLabel: {
                            Text("\(temperature)")
                                .font(.title3)
                        }
                        .tint(Gradient(colors: [planetColor.opacity(0.7), planetColor, planetColor.opacity(0.75)]))
                        .gaugeStyle(AccessoryCircularGaugeStyle())
                        .scaleEffect(1.2)
                    }
                    .padding()
                }
            }
        }

        HStack {
            Text("Planets farther from the Sun have lower temperatures, highlighting the impact of solar distance on planetary climates.")
                .fontDesign(.rounded)
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()
        }
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
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.body)
                    .fontDesign(.rounded)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(value).foregroundStyle(.BETRAYED)
                        .font(.title)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)

                    if unit == "moons" && value == "1" {
                        Text("moon")
                            .font(.title3)
                            .fontDesign(.rounded)
                            .fontWeight(.medium)
                            .foregroundStyle(color)
                    } else {
                        Text(unit)
                            .font(.title3)
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
                    .buttonStyle(.plain)
                }
                Spacer()
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}
