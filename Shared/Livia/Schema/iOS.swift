//
//  iOS.swift
//  Cosmofy
//

import Foundation

#if os(iOS)
extension schema {

    static let query = """
        query($date: String, $daysInput: Int) {
            picture(date: $date) {
                date
                title
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
                name
                description
                expandedDescription
                visual
                moons
                rings
                mass
                volume
                density
                temperature
                pressure
                escapeVelocity
                gravityEquatorial
                orbitalInclination
                orbitalVelocity
                radiusEquatorial
                flattening
                obliquityToOrbit
                siderealOrbitPeriodY
                siderealRotationPeriod
                solarDayLength
                albedo
                facts
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
                }
                geometry {
                    coordinates
                    date
                }
            }
            articles {
                month
                year
                title
                url
                authors {
                    name
                }
                banner {
                    image
                }
            }
        }
    """
}
#endif
