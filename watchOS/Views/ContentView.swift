//
//  ContentView.swift
//  WatchCosmofy Watch App
//
//  Created by Arryan Bhatnagar on 6/15/24.
//

import SwiftUI
import Combine

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: PlanetsView()) {
                    VStack {
                        HStack {
                            Image("home-icon-4")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Spacer()
                        }
                        HStack {
                            Text("Planets")
                                .multilineTextAlignment(.leading)
                                .font(.caption)
                            Spacer()
                        }
                        HStack {
                            Text("Explore each planet in 3D and view their fascinating details.")
                                .multilineTextAlignment(.leading)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        
                    }
                    .padding(.vertical)
                }
                .frame(maxWidth: .infinity)
                NavigationLink(destination: LeftView()) {
                    VStack {
                        HStack {
                            Image("home-icon-2")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Spacer()
                        }
                        HStack {
                            Text("Picture of the Day")
                                .multilineTextAlignment(.leading)
                                .font(.caption)
                            Spacer()
                        }
                        HStack {
                            Text("View a new astronomy image every day")
                                .multilineTextAlignment(.leading)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        
                    }
                    .padding(.vertical)
                }
                .frame(maxWidth: .infinity)
                NavigationLink(destination: SwiftView()) {
                    VStack {
                        HStack {
                            Image("swift")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Spacer()
                        }
                        HStack {
                            Text("Swift")
                                .multilineTextAlignment(.leading)
                                .font(.caption)
                            Spacer()
                        }
                        HStack {
                            Text("Ask a question about the cosmos")
                                .multilineTextAlignment(.leading)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                    .padding(.vertical)
                }
                .frame(maxWidth: .infinity)
            }
            .listStyle(CarouselListStyle())
            .navigationTitle("Cosmofy")
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    ShareLink(item: URL(string: "https://apps.apple.com/app/cosmofy/id6450969556")!, preview: SharePreview("Cosmofy on the Apple App Store", image: Image("iconApp")))
                }
            }
        }
    }
}


#Preview {
    ContentView()
}

struct WordByWordTextView: View {
    let fullText: String
    let animationInterval: TimeInterval
    @State private var displayedText: String = ""
    private let words: [String]
    
    init(_ text: String, interval: TimeInterval = 0.35) {
        self.fullText = text
        self.animationInterval = interval
        self.words = text.split { $0.isWhitespace }.map(String.init)
    }
    
    var body: some View {
        HStack {
            Text(displayedText)
                .onAppear {
                    if displayedText == "" {
                        DispatchQueue.main.async {
                            self.animateText()
                        }
                    }
                }
            Spacer()
        }
    }
    
    private func animateText() {
        var currentWordIndex = 0
        Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: true) { timer in
            if currentWordIndex < words.count {
                let word = words[currentWordIndex]
                displayedText += (currentWordIndex == 0 ? "" : " ") + word
                currentWordIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
}
