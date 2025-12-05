//
//  iPadPlanetView.swift
//  Cosmofy
//
//  Created by Arryan Bhatnagar on 6/28/24.
//

import Foundation
import SwiftUI
import SceneKit

struct iPadPlanetView: View {
    
    var planet: Planet
    @State private var isPresented = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            HStack {
                ZStack {
                    SceneView(
                        scene: createPlanetScene(planetName: planet.name.lowercased(), isFullScreen: false, platform: nil).scene,
                        options: [.allowsCameraControl, .autoenablesDefaultLighting]
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                self.isPresented.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.down.left.and.arrow.up.right")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.white.opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .padding()
                            }
                            .padding(8)
                            .fullScreenCover(isPresented: $isPresented) {
                                SomeView(planet: planet)
                            }
                        }
                        Spacer()
                    }

                    VStack {
                        Spacer()
                        HStack {
                            Text(" SceneKit")
                                .font(Font.custom("SF Pro Rounded Semibold", size: 22))
                                .foregroundColor(.white)
                                .padding([.bottom], 20)
                                .padding([.leading], 24)
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .frame(maxHeight: .infinity)
                

                VStack {
                    VStack {
                        HStack {
                            Text("First Human Visual Observation")
                                .font(Font.custom("SF Pro Rounded Regular", size: 16))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        HStack {
                            Text(planet.visual)
                                .font(Font.custom("SF Pro Rounded Regular", size: 16))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    .padding()
                    
                    HStack {
                        Text(planet.expandedDescription)
                        #if !os(tvOS)
                            .textSelection(.enabled)
                        #endif
                            .multilineTextAlignment(.leading)
                            .italic()
                            .font(.body)
                            .fontDesign(.serif)
                        Spacer()
                    }
                    .padding(.horizontal)

                    VStack(spacing: 16) {
                        
                        HStack {
                            PlanetPropertyView(title: "Natural Satellites", value: String(planet.moons), unit: "moons", color: planet.color)
                            PlanetPropertyView(title: "Planetary Rings", value: String(planet.rings), unit: "rings", color: planet.color)
                        }

                        
                        HStack {
                            PlanetPropertyView(title: "Gravity", value: String(planet.gravity), unit: "m/s²", color: planet.color)
                            PlanetPropertyView(title: "Escape Velocity", value: planet.escapeVelocity, unit: "km/h", color: planet.color)
                        }
                        
                        PlanetPropertyView(title: "Equatorial Radius", value: planet.radius, unit: "km", color: planet.color)
                        PlanetPropertyView(title: "Mass", value: planet.mass, unit: "kg", color: planet.color)
                        PlanetPropertyView(title: "Volume", value: planet.volume, unit: "km³", color: planet.color)
                        
                        HStack() {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Atmosphere")
                                    .font(Font.custom("SF Pro Rounded Medium", size: 16))
                                    .foregroundColor(.secondary)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack() {
                                        ForEach(planet.atmosphere) { atmos in
                                            iPadAtmosphereView(planet: planet, atmosphere: atmos)
                                        }
                                    }
                                }
                            }
                            Spacer()
                        }

                    }
                    .padding()
                }
                .padding(.horizontal)


            }
            .padding()
            .background(colorScheme == .dark ? Color.init(hex: 0x0F0F15) : Color.clear) // Apply background only in dark mode
            // 0F0F15 0x181C22
            .navigationTitle(planet.name)
//            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
#if !os(tvOS)
                UINavigationBar.appearance().largeTitleTextAttributes = [
                    .font: UIFont(name: "SF Pro Rounded Bold", size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .semibold),
                ]
                #endif
            }
#if !os(tvOS)
            .navigationBarItems(
                trailing: ShareLink(item: URL(string: "https://apps.apple.com/app/cosmofy/id6450969556")!, preview: SharePreview("Cosmofy on the Apple App Store", image: Image("iconApp")))
                    .foregroundStyle(planet.color)
            )
#endif
        }
    }
}



#Preview {
    iPadPlanetView(planet: neptunePlanet)
}

struct SomeView: View {
    let backgroundGradient = LinearGradient(
        colors: [Color.cyan, Color.blue],
        startPoint: .top, endPoint: .bottom)
    var planet: Planet
    
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedViewType: Int = 0
    
    var body: some View {
        ZStack {

            SceneView(
                scene: createPlanetScene(planetName: planet.name.lowercased(), isFullScreen: true, platform: nil).scene,
                options: [.allowsCameraControl, .autoenablesDefaultLighting]
            )
            .edgesIgnoringSafeArea(.all)

            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill") // The icon
                            .resizable()
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(width: 30, height: 30)
                            .padding(.top, 64)
                            .padding(.trailing, 16)
                    }
                }
                Spacer()
            }
            
            
            
        }
        .ignoresSafeArea()

    }

}

struct iPadAtmosphereView: View {
    var planet: Planet
    var atmosphere: Atmosphere

    private var boxWidth: CGFloat {
        let formulaLength = atmosphere.formula.count
        if formulaLength <= 2 {
            return 42
        } else if formulaLength <= 4 {
            return 52
        } else {
            return 62
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(planet.color.gradient)

            VStack {
                HStack {
                    Spacer()
                    Text(atmosphere.molar)
                        .font(.caption2)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .padding(.trailing, 3)
                .padding(.top, 3)

                HStack {
                    Text(atmosphere.formula)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.leading, 4)
                .padding(.bottom, 3)
            }
        }
        .frame(width: boxWidth, height: 42)
        .cornerRadius(8)
    }
}

