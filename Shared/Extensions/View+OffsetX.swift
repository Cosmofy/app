#if swift(>=5.9)
//
//  View+OffsetX.swift
//  Cosmofy
//
//  Created by Arryan Bhatnagar on 3/11/24.
//

import Foundation
import SwiftUI

@available(iOS 17.0, *)
struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

@available(iOS 17.0, *)
extension View {

    @ViewBuilder
    func offsetX(completion: @escaping (CGFloat) -> ()) -> some View {
        self.overlay {
            GeometryReader {
                let minX = $0.frame(in: .scrollView(axis: .horizontal)).minX
                Color.clear
                    .preference(key: OffsetKey.self, value: minX)
                    .onPreferenceChange(OffsetKey.self, perform: completion)
            }
        }
    }

}
#endif
