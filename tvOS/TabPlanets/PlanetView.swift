//
//  TVPlanetView.swift
//  Cosmofy
//
//  Created by Arryan Bhatnagar on 7/11/24.
//

import Foundation
import SwiftUI
import SceneKit

struct PlanetView: View {
    
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
                    .frame(maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                self.isPresented.toggle()
                            }) {
                                Image(systemName: "arrow.down.left.and.arrow.up.right")
                                    .font(.caption2)
                                    .frame(maxWidth: 20, maxHeight: 16)
                                
                            }
                            .fullScreenCover(isPresented: $isPresented) {
                                Planet3D(planet: planet, coordinator: Coordinator(planetName: planet.name, isFullScreen: true, platform: "TV"))
                            }
                        }
                        
                       Spacer()
                    }
                    .padding(48)

                    Text(" SceneKit")
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .padding(32)

                    Spacer()
                }
                VStack {
                    
                    HStack {
                        Text(planet.name)
                            .padding(.horizontal)
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.bottom)
                            .fontDesign(.rounded)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    VStack {
                        HStack {
                            
                            if !(planet.name == "Earth") {
                                Text("First Human Visual Observation")
                                    .font(.caption2)
                                    .fontDesign(.rounded)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Earth was always perceived as a planet")
                                    .font(.caption2)
                                    .fontDesign(.rounded)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            
                            Text(planet.visual)
                                .font(.caption2)
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    
                    HStack {
                        Text(planet.expandedDescription)
                        #if !os(tvOS)
                            .textSelection(.enabled)
                        #endif
                            .multilineTextAlignment(.leading)
                            .italic()
                            .font(.caption2)
                            .fontDesign(.serif)
                            .padding(.horizontal)
                        Spacer()
                    }
                    .padding(.horizontal)

                    VStack(spacing: 32) {
                        
                        HStack {
                            PlanetPropertyView(title: "Natural Satellites", value: String(planet.moons), unit: "moons", color: planet.color)
                            PlanetPropertyView(title: "Planetary Rings", value: String(planet.rings), unit: "rings", color: planet.color)
                        }

                        
                        HStack {
                            PlanetPropertyView(title: "Gravity", value: String(planet.gravity), unit: "m/s²", color: planet.color)
                            PlanetPropertyView(title: "Escape Velocity", value: planet.escapeVelocity, unit: "km/h", color: planet.color)
                        }
                        
                        HStack {
                            PlanetPropertyView(title: "Equatorial Radius", value: planet.radius, unit: "km", color: planet.color)
                            PlanetPropertyView(title: "Mass", value: planet.mass, unit: "kg", color: planet.color)
                        }
                        

                        PlanetPropertyView(title: "Volume", value: planet.volume, unit: "km³", color: planet.color)

                        HStack() {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Atmosphere")
                                    .fontWeight(.medium)
                                    .font(.caption2)
                                    .fontDesign(.rounded)
                                    .foregroundColor(.secondary)
                                HStack(spacing: 16) {
                                    ForEach(planet.atmosphere) { atmos in
                                        AtmosphereView(planet: planet, atmosphere: atmos)
                                            
                                    }
                                }
                            }
                            .padding(.horizontal)
                            Spacer()
                        }
                        


                    }
                    .padding()
                }
                .padding(.leading)


            }
            .padding()
        }
    }
}


struct Planet3D: View {
    let backgroundGradient = LinearGradient(
        colors: [Color.cyan, Color.blue],
        startPoint: .top, endPoint: .bottom)
    var planet: Planet
    
    @Environment (\.presentationMode) var presentationMode
    @State private var selectedViewType: Int = 0
    
    @ObservedObject var coordinator: Coordinator
    
    var body: some View {
        ZStack {

            SceneView(
                scene: coordinator.scene,
                options: [.allowsCameraControl, .autoenablesDefaultLighting]
            )
            .edgesIgnoringSafeArea(.all)

            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .font(.caption2)
                            .frame(width: 30, height: 30)
                    }
                }
                Spacer()
            }
            .padding(48)
            
            
        }
        .ignoresSafeArea()
        .onPlayPauseCommand(perform: {
            coordinator.toggleRotation()
        }
        )

    }
    
}

struct PlanetPropertyView: View {
    var title: String
    var value: String
    var unit: String
    var color: Color
    @State private var topExpanded: Bool = true
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.medium)
                    .font(.caption2)
                    .fontDesign(.rounded)
                    .foregroundColor(.secondary)
                HStack(spacing: 12) {
                    
                    Text(value).foregroundStyle(.BETRAYED)
                        .fontWeight(.semibold)
                        .font(.caption)
                        .fontDesign(.rounded)
                    
                    if (unit == "moons" && value == "1") {
                        Text("moon")
                            .fontWeight(.semibold)
                            .font(.caption2)
                            .fontDesign(.rounded)
                            .foregroundStyle(color)
                    } else {
                        Text(unit)
                            .fontWeight(.semibold)
                            .font(.caption2)
                            .fontDesign(.rounded)
                            .foregroundStyle(color)
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}


#Preview {
    PlanetView(planet: neptunePlanet)
}

struct AtmosphereView: View {
    var planet: Planet
    var atmosphere: Atmosphere

    private var boxWidth: CGFloat {
        let formulaLength = atmosphere.formula.count
        if formulaLength <= 2 {
            return 60
        } else if formulaLength <= 4 {
            return 75
        } else {
            return 90
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(planet.color.gradient)

            Text(atmosphere.formula)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(width: boxWidth, height: 60)
        .cornerRadius(8)
    }
}
