//
//  PlanetsView.swift
//  WatchCosmofy Watch App
//
//  Created by Arryan Bhatnagar on 6/17/24.
//

import Foundation
import SwiftUI
import SceneKit


struct PlanetsView: View {
    @State private var selectedPlanet: Planet? = nil
    
    var body: some View {
        NavigationStack {
            TabView {
                ForEach(allPlanets) { planet in
                    ZStack {
                        PlanetPreview(planet: planet)
                            .containerBackground(planet.color.gradient, for: .tabView)
                            .onTapGesture {
                                selectedPlanet = planet
                            }
                    }
                }
            }
            .navigationTitle("Planets")

        }
        .tabViewStyle(.verticalPage)
        .sheet(item: $selectedPlanet) { planet in
            PlanetDetailView(planet: planet)
        }
    }
}

struct PlanetDetailView: View {
    let planet: Planet
    @State private var show3DView = false
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text(planet.name)
                        .fontWeight(.medium)
                        .font(.title2)
                    Spacer()
                }
                .padding()
                
                
                HStack {
                    Button("View in 3D")
                    {
                        show3DView.toggle()
                    }
                    .buttonStyle(BorderedButtonStyle(tint: .clear))
                    .foregroundColor(.white)
                    .sheet(isPresented: $show3DView) {
                        SceneView(
                            scene: createPlanetScene(planetName: planet.name.lowercased()),
                            options: [.allowsCameraControl, .autoenablesDefaultLighting]
                        )
                        .edgesIgnoringSafeArea(.all)
                    }
                }
                .background(planet.color)
                .cornerRadius(16)
                .padding(.bottom)
                
                
                VStack(spacing: 8) {
                    PlanetPropertyView(title: "Natural Satellites", value: String(planet.moons), unit: "moons", color: planet.color)
                    
                    PlanetPropertyView(title: "Planetary Rings", value: String(planet.rings), unit: "rings", color: planet.color)
                    
                    PlanetPropertyView(title: "Gravity", value: String(planet.gravity), unit: "m/s²", color: planet.color)
                    
                    PlanetPropertyView(title: "Escape Velocity", value: planet.escapeVelocity, unit: "km/h", color: planet.color)
                    
                    PlanetPropertyView(title: "Equatorial Radius", value: planet.radius, unit: "km", color: planet.color)
                    
                    PlanetPropertyView(title: "Mass", value: planet.mass, unit: "kg", color: planet.color)
                    
                    PlanetPropertyView(title: "Volume", value: planet.volume, unit: "km³", color: planet.color)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Atmosphere")
                            .font(.caption2)
                        
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack() {
                                ForEach(planet.atmosphere) { atmos in
                                    AtmosphereView(planet: planet, atmosphere: atmos)
//                                    Image(image)
//                                        .resizable()
//                                        .frame(width: 40, height: 40)
//                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                    }
                    .padding(.horizontal)
                }
                
                
            }
        }
        
    }
}

struct PlanetPropertyView: View {
    var title: String
    var value: String
    var unit: String
    var color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                HStack(alignment: .firstTextBaseline) {
                    Text(value)
                        .bold()
                    if (unit == "moons" && value == "1") {
                        Text("moon")
                            .font(.caption2)
                            .foregroundStyle(color)
                    } else {
                        Text(unit)
                            .font(.caption2)
                            .foregroundStyle(color)
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}


struct PlanetPreview: View {
    let planet: Planet
    var body: some View {
        VStack {
            Image(planet.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 65)
            
            Spacer()
            
            HStack {
                Text(planet.name)
                    .fontWeight(.medium)
                    .font(.title2)
                Spacer()
            }
            HStack {
                Text(planet.description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

class PlanetNode: SCNNode {
    var global = 0.0
    
    init(radius: Double, planet: String, rotation: Double, axialTilt: Double) {
        super.init()
        
        self.position = SCNVector3(0, 0, 0)
        global = rotation
        
        switch(planet) {
        case "mercury": createPlanet(planet: "Mercury", semiMajorAxis: 1.0, semiMinorAxis: 1.0, axialTilt: axialTilt); break
        case "venus": createPlanet(planet: "Venus", semiMajorAxis: 1.0, semiMinorAxis: 1.0, axialTilt: axialTilt); break
        case "earth":
            createPlanet(planet: "Earth", semiMajorAxis: 1.0, semiMinorAxis: 1.0, axialTilt: axialTilt)
            self.geometry?.firstMaterial?.specular.contents = UIImage(named: "map-earth-specular")
            self.geometry?.firstMaterial?.emission.contents = UIImage(named: "map-earth-emission")
            self.geometry?.firstMaterial?.normal.contents = UIImage(named: "map-earth-normal")
            break
        case "mars": createPlanet(planet: "Mars", semiMajorAxis: 1.0, semiMinorAxis: 1.0, axialTilt: axialTilt); break
        case "jupiter": createJupiter(axialTilt: axialTilt); break
        case "saturn": createSaturn(axialTilt: axialTilt); break
        case "uranus": createPlanet(planet: "Uranus", semiMajorAxis: 1.0, semiMinorAxis: 0.97, axialTilt: axialTilt); break
        case "neptune": createPlanet(planet: "Neptune", semiMajorAxis: 1.0, semiMinorAxis: 0.97, axialTilt: axialTilt); break
        default: break
        }
        
        startRotation()
    }
    
    func createPlanet(planet: String, semiMajorAxis: Double, semiMinorAxis: Double, axialTilt: Double) {
        let sphereGeometry = SCNSphere(radius: 1.0)
        sphereGeometry.segmentCount = 72
        let sphereNode = SCNNode(geometry: sphereGeometry)
        
        // Apply scaling to the sphere node to deform it into an ellipsoid
        sphereNode.scale = SCNVector3(x: Float(semiMajorAxis), y: Float(semiMinorAxis), z: Float(1.0))
        
        // Apply axial tilt
        sphereNode.eulerAngles = SCNVector3(x: 0, y: 0, z: Float(axialTilt * .pi / 180))
        
        // Apply textures or materials as needed
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "map-\(planet.lowercased())")
        material.diffuse.mipFilter = SCNFilterMode.linear
        sphereGeometry.materials = [material]
        
        self.addChildNode(sphereNode)
    }
    
    func createJupiter(axialTilt: Double) {
        createPlanet(planet: "Jupiter", semiMajorAxis: 1.0, semiMinorAxis: 0.935, axialTilt: axialTilt)
    }
    
    func createSaturn(axialTilt: Double) {
        createPlanet(planet: "Saturn", semiMajorAxis: 1.0, semiMinorAxis: 0.902, axialTilt: axialTilt)
    }
    
    func stopRotation() {
        self.removeAllActions()
    }
    
    func startRotation() {
        let action = SCNAction.rotateBy(x: 0, y: 0.6, z: 0, duration: global)
        let repeatAction = SCNAction.repeatForever(action)
        self.runAction(repeatAction)
    }
    
    func setRotation(r: Double) {
        global = r
    }
    
    required init?(coder x: NSCoder) {
        super.init(coder: x)
    }
}

func createPlanetScene(planetName: String) -> SCNScene {
    let scene = SCNScene()
    
    // Axial tilts for planets
    let axialTilts: [String: Double] = [
        "mercury": -0.034,
        "venus": -177.4,
        "earth": -23.4,
        "mars": -25.2,
        "jupiter": -3.1,
        "saturn": -26.7,
        "uranus": -97.8,
        "neptune": -28.3
    ]
    
    let planetNode = PlanetNode(
        radius: 1,
        planet: planetName,
        rotation: 10,
        axialTilt: axialTilts[planetName.lowercased()] ?? 0.0
    )
    planetNode.position = SCNVector3(0, -0.15, 0) // Center the node
    scene.rootNode.addChildNode(planetNode)
    
    if planetName == "saturn" {
        let saturnLoop = SCNBox(width: 4.444, height: 0, length: 5.556, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "map-saturn-ring")
        saturnLoop.materials = [material]
        let loopNode = SCNNode(geometry: saturnLoop)
        loopNode.position = SCNVector3(x: 0, y: 0, z: 0)
        loopNode.eulerAngles = SCNVector3(x: 0, y: 0, z: Float(-26.7 * .pi / 180))
        planetNode.addChildNode(loopNode)
    }
    
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    //    cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
    if planetName == "saturn" {
        cameraNode.position = SCNVector3(x: 0, y: 1.5, z: 5.5)
        cameraNode.eulerAngles = SCNVector3(x: -Float.pi / 10, y: 0, z: 0)
    } else {
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 3.5)
    }
    scene.rootNode.addChildNode(cameraNode)
    
    return scene
}

struct AtmosphereView: View {
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
