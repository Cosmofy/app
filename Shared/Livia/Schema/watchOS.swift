//
//  watchOS.swift
//  Cosmofy
//

import Foundation

#if os(watchOS)
extension schema {

    static let query = """
        query($date: String) {
            picture(date: $date) {
                date
                title
                media
                media_type
                explanation {
                    original
                }
            }
        }
    """
}
#endif
