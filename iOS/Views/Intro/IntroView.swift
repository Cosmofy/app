#if swift(>=5.9)
//
//  IntroView.swift
//  Cosmofy iOS
//
//  Created by Arryan Bhatnagar on 7/29/24.
//

import SwiftUI

@available(iOS 17.0, *)
struct IntroView: View {

    @AppStorage("signed_in") var currentUserSignedIn: Bool = false
    @AppStorage("selectedProfile") var currentSelectedProfile: Int?
    @ObservedObject var gqlViewModel: GQLViewModel

    var tranition: AnyTransition = .opacity

    var body: some View {
        VStack {
            if currentUserSignedIn {
                switch currentSelectedProfile {
                case 1:
                    TabBarKids(gqlViewModel: gqlViewModel)
                        .transition(tranition)
                case 2:
                    TabBarView(gqlViewModel: gqlViewModel)
                        .transition(tranition)
                default:
                    TabBarView(gqlViewModel: gqlViewModel)
                        .transition(tranition)
                }
            } else {
                OnboardingView()
                    .transition(tranition)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: currentUserSignedIn)
        .animation(.easeInOut(duration: 0.5), value: currentSelectedProfile)
    }
}
#endif
