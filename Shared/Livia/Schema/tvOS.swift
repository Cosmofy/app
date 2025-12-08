//
//  tvOS.swift
//  Cosmofy
//

import Foundation

#if os(tvOS)
extension schema {

    static let query = """
        query($date: String, $daysInput: Int) {
            picture(date: $date) {
                date
                title
                media
                media_type
                explanation {
                    original
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
        }
    """
}
#endif
