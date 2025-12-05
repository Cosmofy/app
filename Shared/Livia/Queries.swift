//
//  Queries.swift
//  Cosmofy
//
//  Created by Arryan Bhatnagar on 12/3/24.
//

import Foundation

// MARK: - Queries

enum Queries {

    // MARK: Health Check
    static let serverStatus = """
        query {
            server
            time
        }
    """

    // MARK: Picture of the Day
    static let picture = """
        query Picture($date: String) {
            picture(date: $date) {
                date
                title
                credit
                copyright
                media
                media_type
                explanation {
                    original
                    summarized
                    kids
                }
            }
        }
    """

    // MARK: Events
    static let events = """
        query Events($daysInput: Int) {
            events(daysInput: $daysInput) {
                id
                title
                categories {
                    id
                    title
                }
                sources {
                    id
                    url
                }
                geometry {
                    id
                    magnitudeValue
                    magnitudeUnit
                    date
                    type
                    coordinates
                }
            }
        }
    """

    // MARK: Planets (full schema)
    static let planets = """
        query {
            planets {
                id
                name
                description
                expandedDescription
                facts
                visual
                lastUpdated
                moons
                rings
                mass
                volume
                density
                temperature
                pressure
                escapeVelocity
                gravityEquatorial
                gravityPolar
                orbitalInclination
                orbitalVelocity
                radiusEquatorial
                radiusPolar
                radiusCore
                radiusHillsSphere
                volumetricMeanRadius
                angularDiameter
                momentOfInertia
                flattening
                gravitationalParameter
                gravitationalParameterUncertainty
                rockyCoreMass
                obliquityToOrbit
                siderealOrbitPeriodD
                siderealOrbitPeriodY
                siderealRotationRate
                siderealRotationPeriod
                solarDayLength
                albedo
                visualMagnitude
                visualMagnitudeOpposition
                rocheLimit
                solarConstant {
                    perihelion
                    aphelion
                    mean
                }
                maxIR {
                    perihelion
                    aphelion
                    mean
                }
                minIR {
                    perihelion
                    aphelion
                    mean
                }
                atmosphere {
                    name
                    molar
                    formula
                    percentage
                }
            }
        }
    """

    // MARK: Articles
    static let articles = """
        query {
            articles {
                month
                year
                title
                subtitle
                url
                source
                authors {
                    name
                    title
                    image
                }
                banner {
                    image
                    designer
                }
            }
        }
    """
}
