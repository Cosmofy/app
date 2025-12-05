//
//  iPadPlanetsView.swift
//  Cosmofy
//
//  Created by Arryan Bhatnagar on 6/28/24.
//

import SwiftUI

struct iPadPlanetsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    iPadPlanetSmall(planet: mercuryPlanet)
                        .padding()
                    iPadPlanetSmall(planet: venusPlanet)
                        .padding()
                    iPadPlanetSmall(planet: earthPlanet)
                        .padding()
                    iPadPlanetSmall(planet: marsPlanet)
                        .padding()
                }
                
                HStack {
                    iPadPlanetSmall(planet: jupiterPlanet)
                        .padding()
                    iPadPlanetSmall(planet: saturnPlanet)
                        .padding()
                    iPadPlanetSmall(planet: uranusPlanet)
                        .padding()
                    iPadPlanetSmall(planet: neptunePlanet)
                        .padding()
                }
            }
            .padding()
            .navigationTitle("Planets")
            .onAppear {
                #if !os(tvOS)
                UINavigationBar.appearance().largeTitleTextAttributes = [
                    .font: UIFont(name: "SF Pro Rounded Bold", size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .semibold),
                ]
                #endif
            }
            
        }

    }
}

struct iPadPlanetSmall: View {
    var planet: Planet
    var body: some View {
        
        NavigationLink(destination: iPadPlanetView(planet: planet)) {
            VStack {
                HStack {
                    Image(planet.imageName)
                        .resizable()
                        .frame(width: 60, height: 60)
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                HStack {
                    Text(planet.name)
                        .font(Font.custom("SF Pro Rounded Medium", size: 24))

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                HStack {
                    
                    Text(planet.description)
                        .font(Font.custom("SF Pro Rounded Regular", size: 16))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    Spacer()
                }
                
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 32))
        }
    }
}


#Preview {
    iPadPlanetsView()
}
