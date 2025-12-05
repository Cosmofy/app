//
//  Models.swift
//  Cosmofy
//
//  Created by Arryan Bhatnagar on 12/3/24.
//

import Foundation

// MARK: - Response Containers

struct ServerStatusResponse: Decodable {
    let server: String
    let time: Double
}

struct PictureResponse: Decodable {
    let picture: GQLPicture
}

struct GQLEventsResponse: Decodable {
    let events: [GQLEvent]
}

struct PlanetsResponse: Decodable {
    let planets: [GQLPlanet]
}

struct ArticlesResponse: Decodable {
    let articles: [GQLArticle]
}

// MARK: - Picture of the Day

struct GQLPicture: Decodable {
    let date: String?
    let title: String?
    let credit: String?
    let copyright: String?
    let media: String?
    let media_type: String?
    let explanation: GQLExplanation?
}

struct GQLExplanation: Decodable {
    let original: String?
    let summarized: String?
    let kids: String?
}

// MARK: - Events

struct GQLEvent: Decodable, Identifiable, Hashable {
    let id: String
    let title: String?
    let categories: [GQLCategory]?
    let sources: [GQLSource]?
    let geometry: [GQLGeometry]?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: GQLEvent, rhs: GQLEvent) -> Bool {
        lhs.id == rhs.id
    }
}

struct GQLCategory: Decodable, Identifiable, Equatable {
    let id: String
    let title: String?
}

struct GQLSource: Decodable, Identifiable {
    let id: String
    let url: String?
}

struct GQLGeometry: Decodable, Identifiable {
    let id: String?
    let magnitudeValue: Double?
    let magnitudeUnit: String?
    let date: String?
    let type: String?
    let coordinates: [Double]?

    var identifier: String { id ?? UUID().uuidString }
}

// MARK: - Planets

struct GQLPlanet: Decodable, Identifiable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func == (lhs: GQLPlanet, rhs: GQLPlanet) -> Bool {
        lhs.name == rhs.name
    }

    // Basic Info
    let id: Int?
    let name: String?
    let description: String?
    let expandedDescription: String?
    let facts: [String]?
    let visual: String?
    let lastUpdated: String?

    // Physical Properties
    let moons: Int?
    let rings: Int?
    let mass: Double?
    let volume: Double?
    let density: Double?
    let temperature: Int?
    let pressure: Double?
    let radiusEquatorial: Double?
    let radiusPolar: Double?
    let radiusCore: Double?
    let radiusHillsSphere: Double?
    let volumetricMeanRadius: Double?
    let angularDiameter: Double?
    let momentOfInertia: Double?
    let flattening: Double?

    // Gravitational Properties
    let gravityEquatorial: Double?
    let gravityPolar: Double?
    let escapeVelocity: Double?
    let gravitationalParameter: Double?
    let gravitationalParameterUncertainty: Double?
    let rockyCoreMass: Double?

    // Orbital Dynamics & Rotation
    let orbitalInclination: Double?
    let orbitalVelocity: Double?
    let obliquityToOrbit: Double?
    let siderealOrbitPeriodD: Double?
    let siderealOrbitPeriodY: Double?
    let siderealRotationRate: Double?
    let siderealRotationPeriod: Double?
    let solarDayLength: Double?

    // Atmospheric & Optical
    let albedo: Double?
    let visualMagnitude: Double?
    let visualMagnitudeOpposition: Double?

    // Specialized Parameters
    let rocheLimit: Double?
    let solarConstant: GQLOrbitalRadiation?
    let maxIR: GQLOrbitalRadiation?
    let minIR: GQLOrbitalRadiation?

    // Atmosphere
    let atmosphere: [GQLComponent]?
}

struct GQLComponent: Decodable, Identifiable {
    let name: String?
    let molar: Int?
    let formula: String?
    let percentage: Double?

    var id: String { formula ?? UUID().uuidString }
}

struct GQLOrbitalRadiation: Decodable {
    let perihelion: Double?
    let aphelion: Double?
    let mean: Double?
}

// MARK: - Articles

struct GQLArticle: Decodable, Hashable {
    let month: Int?
    let year: Int?
    let title: String?
    let subtitle: String?
    let url: String?
    let source: String?
    let authors: [GQLAuthor]?
    let banner: GQLBanner?

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(month)
        hasher.combine(year)
    }

    static func == (lhs: GQLArticle, rhs: GQLArticle) -> Bool {
        lhs.title == rhs.title && lhs.month == rhs.month && lhs.year == rhs.year
    }
}

struct GQLAuthor: Decodable {
    let name: String?
    let title: String?
    let image: String?
}

struct GQLBanner: Decodable {
    let image: String?
    let designer: String?
}
