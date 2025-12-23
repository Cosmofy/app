#if swift(>=5.9)
//
//  Activities.swift
//  Cosmofy iOS
//
//  Created by Arryan Bhatnagar on 8/3/24.
//

import SwiftUI

@available(iOS 17.0, *)
struct SunArticle: View {
    var body: some View {
        WebView(urlString: "https://kids.nationalgeographic.com/space/article/sun")
            .navigationTitle("The Sun")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: ShareLink(item: URL(string: "https://kids.nationalgeographic.com/space/article/sun")!, preview: SharePreview("Cosmofy's Article about The Sun", image: Image("iconApp")))
            )
    }
}

@available(iOS 17.0, *)
struct AsteroidsArticle: View {
    var body: some View {
        WebView(urlString: "https://kids.nationalgeographic.com/space/article/asteroids")
            .navigationTitle("Asteroids")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: ShareLink(item: URL(string: "https://kids.nationalgeographic.com/space/article/asteroids")!, preview: SharePreview("Cosmofy's Article about Asteroids", image: Image("iconApp")))
            )
    }
}

@available(iOS 17.0, *)
struct TheMoonLandingArticle: View {
    var body: some View {
        WebView(urlString: "https://kids.nationalgeographic.com/history/article/moon-landing")
            .navigationTitle("The Moon Landing")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: ShareLink(item: URL(string: "https://kids.nationalgeographic.com/history/article/moon-landing")!, preview: SharePreview("Cosmofy's Article about The Moon Landing", image: Image("iconApp")))
            )
    }
}
#endif
