//
//  visionOS.swift
//  Cosmofy
//

import Foundation

#if os(visionOS)
extension schema {

    static let query = """
        query($date: String, $daysInput: Int) {
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
#endif
