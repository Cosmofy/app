//
//  View+TabMask.swift
//  Cosmofy
//
//  Created by Arryan Bhatnagar on 3/12/24.
//

import Foundation
import SwiftUI

extension View {
    
    @ViewBuilder
    func tabMask(_ tabProgress: CGFloat) -> some View {
        ZStack {
            self
                .foregroundStyle(.gray)
            
            self
                .symbolVariant(.fill)
                .mask() {
                GeometryReader {
                    let size = $0.size
                    let capsuleWidth = size.width / CGFloat(Tab.allCases.count)
                    
                    Capsule()
                        .frame(width: capsuleWidth)
                        .offset(x: tabProgress * (size.width - capsuleWidth))
                }
            }
        }
    }
}
