//
//  TVPlanetsView.swift
//  Cosmofy
//
//  Created by Arryan Bhatnagar on 7/11/24.
//

import Foundation
import SwiftUI

struct PlanetsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    PlanetSmall(planet: mercuryPlanet)
                        .padding()
                    PlanetSmall(planet: venusPlanet)
                        .padding()
                    PlanetSmall(planet: earthPlanet)
                        .padding()
                    PlanetSmall(planet: marsPlanet)
                        .padding()
                }
                
                HStack {
                    PlanetSmall(planet: jupiterPlanet)
                        .padding()
                    PlanetSmall(planet: saturnPlanet)
                        .padding()
                    PlanetSmall(planet: uranusPlanet)
                        .padding()
                    PlanetSmall(planet: neptunePlanet)
                        .padding()
                }
            }
            .padding()
        }
        
    }
}

struct PlanetSmall: View {
    var planet: Planet
    var body: some View {
        
        NavigationLink(destination: PlanetView(planet: planet)) {
            VStack {
                
                HStack {
                    Text(planet.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                    
                    Spacer()
                    
                    Image(planet.imageName)
                        .resizable()
                        .frame(width: 80, height: 80)
                    
                    
                }
                .padding(.top)
                
                
                Text(planet.description)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .font(.caption2)
                    .fontWeight(.regular)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, -4)
    }
}

