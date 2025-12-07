//
//  KidsPlanetView.swift
//  Cosmofy iOS
//
//  Created by Arryan Bhatnagar on 8/31/24.
//

import Foundation
import SwiftUI

struct KidsPlanetView: View {
    
    var planet: Planet
    @State private var planets: [Planet] = allPlanets
    @State private var isPresented = false

    var body: some View {
        NavigationStack {
            ScrollView {
                
                // MARK: Section 1
                HStack {
                    
                    if planet == earthPlanet {
                        Text("\(planet.order) from the Sun")
                            .font(.title2)
                            .fontDesign(.rounded)
                            .fontWeight(.medium)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.green,
                                        Color.blue,
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    } else {
                        Text("\(planet.order) from the Sun")
                            .font(.title2)
                            .fontDesign(.rounded)
                            .fontWeight(.medium)
                            .foregroundStyle(planet.color.gradient)
                    }


                    Spacer()
                    Image(planet.imageName)
                        .resizable()
                        .frame(width: 50, height: 50)
                    
                }
                .padding()
                
                HStack {


                    
                    Button(action: {
                        self.isPresented.toggle()
                    }) {
                        HStack {
                            Spacer()
                            Text("Explore in 3D")
                                .foregroundStyle(.white)
                                .fontDesign(.rounded)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .frame(height: 55)
                        .background(planet.color.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(8)
                    .fullScreenCover(isPresented: $isPresented) {
                        SomeView(planet: planet)
                    }



                    /*
                    HStack {
                        Spacer()
                        Text("Explore in AR")
                            .foregroundStyle(.white)
                            .fontDesign(.rounded)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .frame(height: 50)
                    .background(planet.color.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                     */

                }
                .padding()
                .padding(.top, -8)
                                    
                VStack {
                    HStack {
                        Text("Get the facts on Neptune, the last gas giant in our solar system.")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    Divider()
                }
                .padding(.horizontal)

                
                HStack {
                    PlanetPropertyView(title: "Natural Satellites", value: String(planet.moons), unit: "moons", color: planet.color)
                    PlanetPropertyView(title: "Planetary Rings", value: String(planet.rings), unit: "rings", color: planet.color)
                }
                .padding()
                
                HStack {
                    PlanetPropertyView(title: "Gravity", value: String(planet.gravity), unit: "m/s²", color: planet.color)
                    PlanetPropertyView(title: "Average Temperature", value: String(planet.averageTemperature), unit: "°C", color: planet.color)
                }
                .padding(.horizontal)

                HStack() {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Atmosphere")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack() {
                                ForEach(planet.atmosphere) { atmos in
                                    KidsAtmosphereView(planet: planet, atmosphere: atmos)
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom)


                
                VStack {
                    HStack {
                        Text("Did you know?")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    Divider()
                }
                .padding(.horizontal)
                .padding(.top)

                VStack {
                    ForEach(planet.facts, id: \.self) { fact in
                        VStack {
                            HStack {
                                Text("Fact")
                                    .fontWeight(.medium)
                                    .textCase(.uppercase)
                                    .fontDesign(.rounded)
                                    .font(.caption)
                                    .foregroundStyle(planet.color.gradient)
                                Spacer()
                            }
                            
                            HStack {
                                Text(fact)
                                    .fontDesign(.rounded)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                    }
                }


                
            }
            .navigationTitle("Mission to \(planet.name)")
            .onAppear {
                UINavigationBar.appearance().largeTitleTextAttributes = [
                    .font: UIFont(name: "SF Pro Rounded Bold", size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .semibold),
                ]
            }
            .navigationBarItems(
                trailing: ShareLink(item: URL(string: "https://apps.apple.com/app/cosmofy/id6450969556")!, preview: SharePreview("Cosmofy on the Apple App Store", image: Image("iconApp")))
                    .foregroundStyle(planet.color)
            )
            
            
        }
        
    }

}

struct KidsAtmosphereView: View {
    var planet: Planet
    var atmosphere: Atmosphere

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
                    Spacer()
                }
                .padding(.leading, 2)
                .padding(.bottom, 3)
            }
        }
        .frame(width: 42, height: 42)
        .cornerRadius(8)
    }
}

#Preview {
    KidsPlanetView(planet: neptunePlanet)
}
