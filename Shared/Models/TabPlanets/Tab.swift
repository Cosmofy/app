//
//  Tab.swift
//  Cosmofy
//
//  Created by Arryan Bhatnagar on 3/11/24.
//

import Foundation
import SwiftUI

enum Tab: String, CaseIterable {
    case inner = "Inner"
    case outer = "Outer"
    case solar = "Solar"
    
    var image: String {
        switch self {
            case .inner:
                return "planets-icon-1"
            case .outer:
                return "planets-icon-2"
            case .solar:
                return "planets-icon-3"
        }
    }
}
