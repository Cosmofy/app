#if swift(>=5.9)
//  ========================================
//  PlanetNode.swift
//  Cosmofy
//  4th Edition
//  Created by Arryan Bhatnagar on 12/30/22.
//  Abstract: A SCNNode class which gets attached into Planet3D
//  ========================================

#if os(macOS)
import AppKit
typealias PlatformImage = NSImage
typealias PlatformColor = NSColor
typealias PlatformFloat = CGFloat
#else
import UIKit
typealias PlatformImage = UIImage
typealias PlatformColor = UIColor
typealias PlatformFloat = Float
#endif

import SceneKit
import SwiftUI
import Combine

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
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
            self.geometry?.firstMaterial?.specular.contents = PlatformImage(named: "map-earth-specular")
            self.geometry?.firstMaterial?.emission.contents = PlatformImage(named: "map-earth-emission")
            self.geometry?.firstMaterial?.normal.contents = PlatformImage(named: "map-earth-normal")
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
        sphereNode.scale = SCNVector3(x: PlatformFloat(semiMajorAxis), y: PlatformFloat(semiMinorAxis), z: PlatformFloat(1.0))

        // Apply axial tilt
        sphereNode.eulerAngles = SCNVector3(x: 0, y: 0, z: PlatformFloat(axialTilt * .pi / 180))

        // Apply textures or materials as needed
        let material = SCNMaterial()
        material.diffuse.contents = PlatformImage(named: "map-\(planet.lowercased())")
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

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
func createPlanetScene(planetName: String, isFullScreen: Bool, platform: String?) -> (scene: SCNScene, planetNode: PlanetNode) {
    let scene = SCNScene()
    scene.background.contents = PlatformColor.black

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


    if planetName == "saturn" {
        let saturnLoop = SCNBox(width: 4.444, height: 0, length: 5.556, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = PlatformImage(named: "map-saturn-ring")
        saturnLoop.materials = [material]
        let loopNode = SCNNode(geometry: saturnLoop)
        loopNode.position = SCNVector3(x: 0, y: 0, z: 0)
        loopNode.eulerAngles = SCNVector3(x: 0, y: 0, z: PlatformFloat(-26.7 * .pi / 180))
        planetNode.addChildNode(loopNode)
    }
    scene.rootNode.addChildNode(planetNode)

    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()

    if isFullScreen {
        if platform == "TV" {
            if planetName == "saturn" {
                cameraNode.position = SCNVector3(x: 0, y: 3, z: 5.5)
                cameraNode.eulerAngles = SCNVector3(x: PlatformFloat(-Double.pi / 10), y: 0, z: 0)
            } else {
                cameraNode.position = SCNVector3(x: 0, y: 0, z: 3.5)
            }
        }
        else {
            if planetName == "saturn" {
                cameraNode.position = SCNVector3(x: 0, y: 3, z: 10)
                cameraNode.eulerAngles = SCNVector3(x: PlatformFloat(-Double.pi / 10), y: 0, z: 0)
            } else {
                cameraNode.position = SCNVector3(x: 0, y: 0, z: 7)
            }
        }

    } else {
        if planetName == "saturn" {
            cameraNode.position = SCNVector3(x: 0, y: 1.5, z: 5.5)
            cameraNode.eulerAngles = SCNVector3(x: PlatformFloat(-Double.pi / 10), y: 0, z: 0)
        } else {
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 3.5)
        }
    }

    scene.rootNode.addChildNode(cameraNode)

    return (scene, planetNode)
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
class Coordinator: ObservableObject {
    var scene: SCNScene
    var planetNode: PlanetNode
    @Published var isPaused: Bool = false
    var cameraNode: SCNNode!


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

    init(planetName: String, isFullScreen: Bool, platform: String?) {
        self.scene = SCNScene()
        self.scene.background.contents = PlatformColor.black
        planetNode = PlanetNode(radius: 1, planet: planetName.lowercased(), rotation: 10, axialTilt: axialTilts[planetName.lowercased()] ?? 0.0)

        planetNode.position = SCNVector3(0, -0.15, 0) // Center the node


        if planetName.lowercased() == "saturn" {
            let saturnLoop = SCNBox(width: 4.444, height: 0, length: 5.556, chamferRadius: 0)
            let material = SCNMaterial()
            material.diffuse.contents = PlatformImage(named: "map-saturn-ring")
            saturnLoop.materials = [material]
            let loopNode = SCNNode(geometry: saturnLoop)
            loopNode.position = SCNVector3(x: 0, y: 0, z: 0)
            loopNode.eulerAngles = SCNVector3(x: 0, y: 0, z: PlatformFloat(-26.7 * .pi / 180))
            self.planetNode.addChildNode(loopNode)
        }
        self.scene.rootNode.addChildNode(planetNode)

        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()

        if isFullScreen {
            if platform == "TV" {
                if planetName == "saturn" {
                    cameraNode.position = SCNVector3(x: 0, y: 3, z: 7.5)
                    cameraNode.eulerAngles = SCNVector3(x: PlatformFloat(-Double.pi / 10), y: 0, z: 0)
                } else {
                    cameraNode.position = SCNVector3(x: 0, y: 0, z: 3.5)
                }
            }
            else {
                if planetName == "saturn" {
                    cameraNode.position = SCNVector3(x: 0, y: 3, z: 10)
                    cameraNode.eulerAngles = SCNVector3(x: PlatformFloat(-Double.pi / 10), y: 0, z: 0)
                } else {
                    cameraNode.position = SCNVector3(x: 0, y: 0, z: 7)
                }
            }

        } else {
            if planetName == "saturn" {
                cameraNode.position = SCNVector3(x: 0, y: 1.5, z: 5.5)
                cameraNode.eulerAngles = SCNVector3(x: PlatformFloat(-Double.pi / 10), y: 0, z: 0)
            } else {
                cameraNode.position = SCNVector3(x: 0, y: 0, z: 3.5)
            }
        }

        scene.rootNode.addChildNode(cameraNode)


        let starsParticleSystem = SCNParticleSystem(named: "StarsParticleSystem.scnp", inDirectory: nil)!
        self.scene.rootNode.addParticleSystem(starsParticleSystem)
    }

    func toggleRotation() {
        if isPaused {
            planetNode.startRotation()
        } else {
            planetNode.stopRotation()
        }
        isPaused.toggle()
    }

    func setRotationSpeed(speed: Double) {
        planetNode.stopRotation()
        planetNode.setRotation(r: speed)
        if !isPaused {
            planetNode.startRotation()
        }
    }

    func moveCameraCloser() {
        print("+")
            cameraNode.position.z -= 0.5
        }

    func moveCameraFurther() {
        print("-")
        cameraNode.position.z += 0.5
    }
}
#endif
