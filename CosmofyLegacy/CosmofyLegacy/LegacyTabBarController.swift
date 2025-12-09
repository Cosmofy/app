//
//  LegacyTabBarController.swift
//  Cosmofy
//
//  Programmatic UIKit Tab Bar for iOS 9-16
//

import UIKit
import SceneKit

class LegacyTabBarController: UITabBarController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }

    // MARK: - Setup

    private func setupTabs() {
        // Home Tab
        let homeVC = LegacyHomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(named: "tab-bar-home")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "tab-bar-home")?.withRenderingMode(.alwaysOriginal)
        )

        // Planets Tab
        let planetsVC = LegacyPlanetsViewController()
        let planetsNav = UINavigationController(rootViewController: planetsVC)
        planetsNav.tabBarItem = UITabBarItem(
            title: "Planets",
            image: UIImage(named: "tab-bar-planets")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "tab-bar-planets")?.withRenderingMode(.alwaysOriginal)
        )

        // Livia Tab
        let liviaVC = LegacyLiviaViewController()
        let liviaNav = UINavigationController(rootViewController: liviaVC)
        liviaNav.tabBarItem = UITabBarItem(
            title: "Livia",
            image: UIImage(named: "tab-bar-livia")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "tab-bar-livia")?.withRenderingMode(.alwaysOriginal)
        )

        // Only 3 tabs: Home, Planets, Livia (no Profile)
        viewControllers = [homeNav, planetsNav, liviaNav]
    }

    private func setupAppearance() {
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
            tabBar.tintColor = .label
        } else {
            tabBar.tintColor = .black
        }
    }
}

// MARK: - Planets View Controller (Exact SwiftUI Layout)

class LegacyPlanetsViewController: UIViewController {

    private var planets: [LegacyPlanet] = []

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            indicator = UIActivityIndicatorView(style: .large)
        } else {
            indicator = UIActivityIndicatorView(style: .gray)
        }
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Planets"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground

            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.largeTitleTextAttributes = [
                .font: roundedPlanetFont(size: 34, weight: .bold)
            ]
            appearance.titleTextAttributes = [
                .font: roundedPlanetFont(size: 17, weight: .semibold)
            ]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            view.backgroundColor = .white
        }

        setupUI()
        fetchPlanets()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func fetchPlanets() {
        loadingIndicator.startAnimating()
        scrollView.isHidden = true

        LegacyAPI.shared.fetchPlanets { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                self?.scrollView.isHidden = false

                switch result {
                case .success(let planets):
                    self?.planets = planets.sorted { ($0.id ?? 0) < ($1.id ?? 0) }
                    self?.buildPlanetList()
                case .failure(let error):
                    print("Failed to fetch planets: \(error)")
                }
            }
        }
    }

    private func buildPlanetList() {
        // Clear existing views
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for planet in planets {
            let planetBlock = createPlanetBlock(planet)
            contentStackView.addArrangedSubview(planetBlock)
        }
    }

    private func createPlanetBlock(_ planet: LegacyPlanet) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        // Planet image (smiling icons)
        let planetImageView = UIImageView()
        planetImageView.translatesAutoresizingMaskIntoConstraints = false
        planetImageView.contentMode = .scaleAspectFit
        planetImageView.image = UIImage(named: smilingImageName(for: planet.name ?? ""))

        // Text container (VStack)
        let textStack = UIStackView()
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading

        // Planet name
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = planet.name ?? "Unknown"
        nameLabel.font = roundedPlanetFont(size: 20, weight: .medium) // .title3 equivalent
        if #available(iOS 13.0, *) {
            nameLabel.textColor = .label
        } else {
            nameLabel.textColor = .black
        }

        // Description
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = planet.description ?? ""
        descriptionLabel.font = roundedPlanetFont(size: 15, weight: .regular) // .subheadline equivalent
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0

        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(descriptionLabel)

        // Chevron
        let chevronImageView = UIImageView()
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.tintColor = .secondaryLabel
        if #available(iOS 13.0, *) {
            chevronImageView.image = UIImage(systemName: "chevron.right")
        } else {
            chevronImageView.image = UIImage(named: "chevron-right")
        }

        container.addSubview(planetImageView)
        container.addSubview(textStack)
        container.addSubview(chevronImageView)

        // Constraints matching SwiftUI layout
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),

            // Planet image - 50x50, leading with 4pt padding + 16 container padding
            planetImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            planetImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            planetImageView.widthAnchor.constraint(equalToConstant: 50),
            planetImageView.heightAnchor.constraint(equalToConstant: 50),

            // Text stack - 16pt from image, fills remaining space
            textStack.leadingAnchor.constraint(equalTo: planetImageView.trailingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            textStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            textStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),

            // Chevron - trailing with padding
            chevronImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32),
            chevronImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20)
        ])

        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(planetTapped(_:)))
        container.addGestureRecognizer(tapGesture)
        container.tag = planets.firstIndex(where: { $0.name == planet.name }) ?? 0

        return container
    }

    @objc private func planetTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag, index < planets.count else { return }
        let planet = planets[index]
        let detailVC = LegacyPlanetDetailViewController(planet: planet)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    private func smilingImageName(for name: String) -> String {
        switch name.lowercased() {
        case "mercury": return "smiling-mercury"
        case "venus": return "smiling-venus"
        case "earth": return "smiling-earth"
        case "mars": return "smiling-mars"
        case "jupiter": return "smiling-jupiter"
        case "saturn": return "smiling-saturn"
        case "uranus": return "smiling-uranus"
        case "neptune": return "smiling-neptune"
        default: return "smiling-earth"
        }
    }
}

// Planet Detail (Exact SwiftUI Layout)
class LegacyPlanetDetailViewController: UIViewController {

    private let planet: LegacyPlanet

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    private var planetColor: UIColor {
        // Colors from Assets.xcassets - exact match to SwiftUI version
        switch planet.name?.lowercased() {
        case "mercury": return UIColor(red: 0.400, green: 0.396, blue: 0.910, alpha: 1) // Purple-blue
        case "venus": return UIColor(red: 0.714, green: 0.576, blue: 0.369, alpha: 1)   // Orange-tan
        case "earth": return UIColor(red: 0.000, green: 0.332, blue: 0.264, alpha: 1)   // Dark teal
        case "mars": return UIColor(red: 0.729, green: 0.373, blue: 0.251, alpha: 1)    // Rusty red
        case "jupiter": return UIColor(red: 0.561, green: 0.498, blue: 0.463, alpha: 1) // Tan-brown
        case "saturn": return UIColor(red: 0.808, green: 0.718, blue: 0.494, alpha: 1)  // Golden yellow
        case "uranus": return UIColor(red: 0.682, green: 0.827, blue: 0.859, alpha: 1)  // Light cyan
        case "neptune": return UIColor(red: 0.420, green: 0.525, blue: 0.965, alpha: 1) // Deep blue
        default: return .systemBlue
        }
    }

    private var planetOrder: String {
        switch planet.name?.lowercased() {
        case "mercury": return "1st"
        case "venus": return "2nd"
        case "earth": return "3rd"
        case "mars": return "4th"
        case "jupiter": return "5th"
        case "saturn": return "6th"
        case "uranus": return "7th"
        case "neptune": return "8th"
        default: return ""
        }
    }

    init(planet: LegacyPlanet) {
        self.planet = planet
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = planet.name
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground

            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.largeTitleTextAttributes = [
                .font: roundedPlanetFont(size: 34, weight: .bold)
            ]
            appearance.titleTextAttributes = [
                .font: roundedPlanetFont(size: 17, weight: .semibold)
            ]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            view.backgroundColor = .white
        }

        setupUI()
        buildContent()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func buildContent() {
        // MARK: Section 1 - Header
        let headerSection = createHeaderSection()
        contentStackView.addArrangedSubview(headerSection)

        // MARK: Planet Image
        let imageSection = createImageSection()
        contentStackView.addArrangedSubview(imageSection)

        // MARK: Description
        let descriptionSection = createDescriptionSection()
        contentStackView.addArrangedSubview(descriptionSection)

        // MARK: Planetary Facts Section Header
        contentStackView.addArrangedSubview(createSectionHeader("PLANETARY FACTS"))

        // Basic Properties - two columns
        contentStackView.addArrangedSubview(createPropertyRow([
            ("Natural Satellites", "\(planet.moons ?? 0)", planet.moons == 1 ? "moon" : "moons"),
            ("Planetary Rings", "\(planet.rings ?? 0)", "rings")
        ]))

        contentStackView.addArrangedSubview(createPropertyRow([
            ("Gravity (Equatorial)", formatDouble(planet.gravityEquatorial), "m/s²"),
            ("Escape Velocity", formatDouble(planet.escapeVelocity), "km/s")
        ]))

        contentStackView.addArrangedSubview(createPropertyRow([
            ("Equatorial Radius", formatScientific(planet.radiusEquatorial), "km")
        ]))

        contentStackView.addArrangedSubview(createPropertyRow([
            ("Mass", formatScientific(planet.mass), "kg")
        ]))

        contentStackView.addArrangedSubview(createPropertyRow([
            ("Volume", formatScientific(planet.volume), "km³")
        ]))

        // MARK: Orbital Parameters Section
        contentStackView.addArrangedSubview(createSectionHeader("ORBITAL PARAMETERS"))

        contentStackView.addArrangedSubview(createPropertyRow([
            ("Orbital Velocity", formatDouble(planet.orbitalVelocity), "km/s"),
            ("Orbital Inclination", formatDouble(planet.orbitalInclination), "°")
        ]))

        contentStackView.addArrangedSubview(createPropertyRow([
            ("Orbit Period", formatDouble(planet.siderealOrbitPeriodY), "years"),
            ("Day Length", formatDouble(planet.solarDayLength), "hours")
        ]))

        contentStackView.addArrangedSubview(createPropertyRow([
            ("Axial Tilt", formatDouble(planet.obliquityToOrbit), "°"),
            ("Rotation Period", formatDouble(planet.siderealRotationPeriod), "hours")
        ]))

        // MARK: Physical Properties Section
        contentStackView.addArrangedSubview(createSectionHeader("PHYSICAL PROPERTIES"))

        contentStackView.addArrangedSubview(createPropertyRow([
            ("Density", formatDouble(planet.density), "g/cm³"),
            ("Flattening", formatDouble(planet.flattening), "")
        ]))

        contentStackView.addArrangedSubview(createPropertyRow([
            ("Surface Pressure", formatDouble(planet.pressure), "bar"),
            ("Albedo", formatDouble(planet.albedo), "")
        ]))

        if let temp = planet.temperature {
            contentStackView.addArrangedSubview(createPropertyRow([
                ("Temperature", "\(temp)", "K")
            ]))
        }

        // MARK: Atmosphere
        if let atmosphere = planet.atmosphere, !atmosphere.isEmpty {
            contentStackView.addArrangedSubview(createAtmosphereSection(atmosphere))
        }

        // MARK: Facts
        if let facts = planet.facts, !facts.isEmpty {
            contentStackView.addArrangedSubview(createSectionHeader("DID YOU KNOW?"))
            contentStackView.addArrangedSubview(createFactsSection(facts))
        }

        // Bottom padding
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 32).isActive = true
        contentStackView.addArrangedSubview(spacer)
    }

    // MARK: - Header Section
    private func createHeaderSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        // Left VStack - visual observation info
        let leftStack = UIStackView()
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        leftStack.axis = .vertical
        leftStack.spacing = 2
        leftStack.alignment = .leading

        let observationTitleLabel = UILabel()
        observationTitleLabel.text = "First Human Visual Observation"
        observationTitleLabel.font = roundedPlanetFont(size: 15, weight: .regular)
        observationTitleLabel.textColor = .secondaryLabel
        observationTitleLabel.numberOfLines = 0

        let observationValueLabel = UILabel()
        observationValueLabel.text = planet.visual ?? "Unknown"
        observationValueLabel.font = roundedPlanetFont(size: 15, weight: .regular)
        observationValueLabel.textColor = .secondaryLabel
        observationValueLabel.numberOfLines = 0

        leftStack.addArrangedSubview(observationTitleLabel)
        leftStack.addArrangedSubview(observationValueLabel)

        // Right - Order circle
        let orderContainer = UIView()
        orderContainer.translatesAutoresizingMaskIntoConstraints = false
        orderContainer.layer.borderColor = planetColor.cgColor
        orderContainer.layer.borderWidth = 4
        orderContainer.layer.cornerRadius = 22

        let orderLabel = UILabel()
        orderLabel.translatesAutoresizingMaskIntoConstraints = false
        orderLabel.text = planetOrder
        orderLabel.font = roundedPlanetFont(size: 15, weight: .semibold)
        if #available(iOS 13.0, *) {
            orderLabel.textColor = .label
        } else {
            orderLabel.textColor = .black
        }
        orderLabel.textAlignment = .center

        orderContainer.addSubview(orderLabel)
        container.addSubview(leftStack)
        container.addSubview(orderContainer)

        NSLayoutConstraint.activate([
            // Remove fixed height - let it size naturally
            leftStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            leftStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            leftStack.trailingAnchor.constraint(equalTo: orderContainer.leadingAnchor, constant: -16),
            leftStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),

            orderContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            orderContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            orderContainer.widthAnchor.constraint(equalToConstant: 44),
            orderContainer.heightAnchor.constraint(equalToConstant: 44),

            orderLabel.centerXAnchor.constraint(equalTo: orderContainer.centerXAnchor),
            orderLabel.centerYAnchor.constraint(equalTo: orderContainer.centerYAnchor)
        ])

        return container
    }

    // Store reference to scene view for fullscreen
    private var planetSceneView: SCNView?
    private var planetSceneName: String = ""

    // MARK: - 3D Planet Section (SceneKit)
    private func createImageSection() -> UIView {
        let outerContainer = UIView()
        outerContainer.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .black
        container.layer.cornerRadius = 30
        container.clipsToBounds = true

        let sceneView = SCNView()
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.backgroundColor = .black
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true

        // Create scene using the existing PlanetNode logic
        let planetName = planet.name?.lowercased() ?? "earth"
        planetSceneName = planetName
        let (scene, _) = createPlanetScene(planetName: planetName, isFullScreen: false, platform: nil)
        sceneView.scene = scene
        planetSceneView = sceneView

        // Expand button (top right) - rounded rectangle with rotated expand icon
        let expandButton = UIButton(type: .system)
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
            // Use the more rotated version of the expand arrows
            expandButton.setImage(UIImage(systemName: "arrow.up.backward.and.arrow.down.forward", withConfiguration: config), for: .normal)
            expandButton.tintColor = .white
        }
        expandButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        expandButton.layer.cornerRadius = 8  // Rounded rectangle instead of circle
        expandButton.addTarget(self, action: #selector(expandPlanetView), for: .touchUpInside)

        // Apple SceneKit label (bottom left) - bigger font, full white, more padding
        let sceneKitLabel = UILabel()
        sceneKitLabel.translatesAutoresizingMaskIntoConstraints = false
        sceneKitLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        sceneKitLabel.textColor = .white

        // Apple logo + SceneKit text
        let attachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            let appleLogoConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
            attachment.image = UIImage(systemName: "apple.logo", withConfiguration: appleLogoConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        }
        let attributedString = NSMutableAttributedString(attachment: attachment)
        attributedString.append(NSAttributedString(string: " SceneKit"))
        sceneKitLabel.attributedText = attributedString

        container.addSubview(sceneView)
        container.addSubview(expandButton)
        container.addSubview(sceneKitLabel)
        outerContainer.addSubview(container)

        // Match horizontal padding to description text below (32pt)
        NSLayoutConstraint.activate([
            outerContainer.heightAnchor.constraint(equalToConstant: 300),

            container.topAnchor.constraint(equalTo: outerContainer.topAnchor),
            container.bottomAnchor.constraint(equalTo: outerContainer.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: outerContainer.leadingAnchor, constant: 32),
            container.trailingAnchor.constraint(equalTo: outerContainer.trailingAnchor, constant: -32),

            sceneView.topAnchor.constraint(equalTo: container.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            expandButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            expandButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            expandButton.widthAnchor.constraint(equalToConstant: 36),
            expandButton.heightAnchor.constraint(equalToConstant: 32),

            sceneKitLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            sceneKitLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])

        return outerContainer
    }

    @objc private func expandPlanetView() {
        let fullscreenVC = LegacyFullscreenPlanetViewController(planetName: planetSceneName)
        fullscreenVC.modalPresentationStyle = .fullScreen
        present(fullscreenVC, animated: true)
    }

    // MARK: - Description Section
    private func createDescriptionSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = planet.expandedDescription ?? planet.description
        descriptionLabel.numberOfLines = 0

        // Italic serif font
        let baseFont = serifPlanetFont(size: 17)
        if let italicDescriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitItalic) {
            descriptionLabel.font = UIFont(descriptor: italicDescriptor, size: 17)
        } else {
            descriptionLabel.font = baseFont
        }
        if #available(iOS 13.0, *) {
            descriptionLabel.textColor = .label
        } else {
            descriptionLabel.textColor = .black
        }

        container.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32),
            descriptionLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])

        return container
    }

    // MARK: - Section Header
    private func createSectionHeader(_ title: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            divider.backgroundColor = .separator
        } else {
            divider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        }

        container.addSubview(label)
        container.addSubview(divider)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32),

            divider.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            divider.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32),
            divider.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32),
            divider.heightAnchor.constraint(equalToConstant: 0.5),
            divider.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    // MARK: - Property Row
    private func createPropertyRow(_ properties: [(String, String, String)]) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let hStack = UIStackView()
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        hStack.spacing = 16

        for (title, value, unit) in properties {
            let propertyView = createPropertyView(title: title, value: value, unit: unit)
            hStack.addArrangedSubview(propertyView)
        }

        container.addSubview(hStack)

        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            hStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32),
            hStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32),
            hStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])

        return container
    }

    private func createPropertyView(title: String, value: String, unit: String) -> UIView {
        let vStack = UIStackView()
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.axis = .vertical
        vStack.spacing = 4
        vStack.alignment = .leading

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = roundedPlanetFont(size: 15, weight: .medium)
        titleLabel.textColor = .secondaryLabel

        let valueStack = UIStackView()
        valueStack.axis = .horizontal
        valueStack.spacing = 4
        valueStack.alignment = .firstBaseline

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = roundedPlanetFont(size: 22, weight: .semibold)
        if #available(iOS 13.0, *) {
            valueLabel.textColor = .label
        } else {
            valueLabel.textColor = .black
        }

        let unitLabel = UILabel()
        unitLabel.text = unit
        unitLabel.font = roundedPlanetFont(size: 15, weight: .medium)
        unitLabel.textColor = planetColor

        valueStack.addArrangedSubview(valueLabel)
        valueStack.addArrangedSubview(unitLabel)

        vStack.addArrangedSubview(titleLabel)
        vStack.addArrangedSubview(valueStack)

        return vStack
    }

    // MARK: - Atmosphere Section
    private func createAtmosphereSection(_ atmosphere: [LegacyAtmosphereComponent]) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Atmosphere"
        titleLabel.font = roundedPlanetFont(size: 15, weight: .medium)
        titleLabel.textColor = .secondaryLabel

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true

        let hStack = UIStackView()
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.axis = .horizontal
        hStack.spacing = 8
        hStack.alignment = .fill  // Changed from .center to .fill to respect child heights
        hStack.distribution = .equalSpacing  // Changed to equalSpacing to not compress boxes

        // Fixed box size for all - always square
        let boxSize: CGFloat = 46

        for component in atmosphere {
            let box = createAtmosphereBox(component, size: boxSize)
            hStack.addArrangedSubview(box)
        }

        scrollView.addSubview(hStack)
        container.addSubview(titleLabel)
        container.addSubview(scrollView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32),
            scrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            scrollView.heightAnchor.constraint(equalToConstant: boxSize),
            scrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),

            hStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hStack.heightAnchor.constraint(equalToConstant: boxSize)  // Fixed height to match box size
        ])

        return container
    }

    private func createAtmosphereBox(_ component: LegacyAtmosphereComponent, size: CGFloat) -> UIView {
        let box = UIView()
        box.translatesAutoresizingMaskIntoConstraints = false
        box.backgroundColor = planetColor
        box.layer.cornerRadius = 8

        // Prevent compression - box must stay at fixed size
        box.setContentHuggingPriority(.required, for: .horizontal)
        box.setContentHuggingPriority(.required, for: .vertical)
        box.setContentCompressionResistancePriority(.required, for: .horizontal)
        box.setContentCompressionResistancePriority(.required, for: .vertical)

        let molarLabel = UILabel()
        molarLabel.translatesAutoresizingMaskIntoConstraints = false
        molarLabel.text = "\(component.molar ?? 0)"
        molarLabel.font = roundedPlanetFont(size: 13, weight: .semibold)
        molarLabel.textColor = .white
        molarLabel.textAlignment = .right

        let formulaLabel = UILabel()
        formulaLabel.translatesAutoresizingMaskIntoConstraints = false
        formulaLabel.text = component.formula ?? ""
        formulaLabel.font = roundedPlanetFont(size: 17, weight: .semibold)
        formulaLabel.textColor = .white
        formulaLabel.adjustsFontSizeToFitWidth = true
        formulaLabel.minimumScaleFactor = 0.7

        box.addSubview(molarLabel)
        box.addSubview(formulaLabel)

        // Fixed size constraints - always square 1:1 with required priority
        let widthConstraint = box.widthAnchor.constraint(equalToConstant: size)
        let heightConstraint = box.heightAnchor.constraint(equalToConstant: size)
        widthConstraint.priority = .required
        heightConstraint.priority = .required

        NSLayoutConstraint.activate([
            widthConstraint,
            heightConstraint,

            molarLabel.topAnchor.constraint(equalTo: box.topAnchor, constant: 4),
            molarLabel.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -5),

            formulaLabel.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 6),
            formulaLabel.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -5),
            formulaLabel.trailingAnchor.constraint(lessThanOrEqualTo: box.trailingAnchor, constant: -4)
        ])

        return box
    }

    // MARK: - Facts Section
    private func createFactsSection(_ facts: [String]) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let vStack = UIStackView()
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.axis = .vertical
        vStack.spacing = 12
        vStack.alignment = .leading

        for fact in facts {
            let factRow = createFactRow(fact)
            vStack.addArrangedSubview(factRow)
        }

        container.addSubview(vStack)

        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            vStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32),
            vStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32),
            vStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    private func createFactRow(_ fact: String) -> UIView {
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.alignment = .top

        let starImageView = UIImageView()
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            starImageView.image = UIImage(systemName: "star.fill")
        } else {
            starImageView.image = UIImage(named: "star-fill")
        }
        starImageView.tintColor = .systemYellow
        starImageView.contentMode = .scaleAspectFit

        let factLabel = UILabel()
        factLabel.text = fact
        factLabel.font = roundedPlanetFont(size: 15, weight: .regular)
        if #available(iOS 13.0, *) {
            factLabel.textColor = .label
        } else {
            factLabel.textColor = .black
        }
        factLabel.numberOfLines = 0

        hStack.addArrangedSubview(starImageView)
        hStack.addArrangedSubview(factLabel)

        NSLayoutConstraint.activate([
            starImageView.widthAnchor.constraint(equalToConstant: 14),
            starImageView.heightAnchor.constraint(equalToConstant: 14)
        ])

        return hStack
    }

    // MARK: - Helpers
    private func formatDouble(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        if value == 0 { return "0" }
        if abs(value) >= 1000 || abs(value) < 0.01 {
            return String(format: "%.2e", value)
        }
        return String(format: "%.2f", value)
    }

    private func formatScientific(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        if value == 0 { return "0" }
        return String(format: "%.3e", value)
    }
}

// MARK: - Fullscreen Planet View Controller
class LegacyFullscreenPlanetViewController: UIViewController {

    private let planetName: String

    init(planetName: String) {
        self.planetName = planetName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        // SceneKit view
        let sceneView = SCNView()
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.backgroundColor = .black
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true

        // Create scene using the existing PlanetNode logic (fullscreen mode)
        let (scene, _) = createPlanetScene(planetName: planetName, isFullScreen: true, platform: nil)
        sceneView.scene = scene

        // Close button (top right)
        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            closeButton.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
            closeButton.tintColor = .white
        } else {
            closeButton.setTitle("Close", for: .normal)
            closeButton.setTitleColor(.white, for: .normal)
        }
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        view.addSubview(sceneView)
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// Livia Chat (Exact SwiftUI Layout)
class LegacyLiviaViewController: UIViewController {

    private var messages: [(role: String, content: String, image: String, isTyping: Bool)] = []

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        tv.register(LiviaChatMessageCell.self, forCellReuseIdentifier: "ChatCell")
        tv.separatorStyle = .none
        tv.keyboardDismissMode = .interactive
        // Enable self-sizing cells for multi-line messages
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 100
        if #available(iOS 13.0, *) {
            tv.backgroundColor = .systemBackground
        } else {
            tv.backgroundColor = .white
        }
        return tv
    }()

    private lazy var inputContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var userImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "user")
        return iv
    }()

    private lazy var textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Ask away..."
        tf.borderStyle = .roundedRect
        tf.returnKeyType = .send
        tf.delegate = self
        return tf
    }()

    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
            button.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: config), for: .normal)
            button.tintColor = UIColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0) // .SOUR color
        } else {
            button.setTitle("Send", for: .normal)
        }
        button.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        return button
    }()

    private var inputContainerBottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Livia"
        navigationController?.navigationBar.prefersLargeTitles = true

        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground

            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.largeTitleTextAttributes = [
                .font: roundedPlanetFont(size: 34, weight: .bold)
            ]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            view.backgroundColor = .white
        }

        setupUI()
        setupKeyboardObservers()

        // Welcome message
        messages.append((role: "assistant", content: "Hello! I'm Livia, your space assistant. Ask me anything about astronomy, planets, or the cosmos!", image: "openai", isTyping: false))
        tableView.reloadData()
    }

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(inputContainer)
        inputContainer.addSubview(userImageView)
        inputContainer.addSubview(textField)
        inputContainer.addSubview(sendButton)

        inputContainerBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerBottomConstraint,
            inputContainer.heightAnchor.constraint(equalToConstant: 60),

            userImageView.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
            userImageView.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            userImageView.widthAnchor.constraint(equalToConstant: 30),
            userImageView.heightAnchor.constraint(equalToConstant: 30),

            textField.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 8),
            textField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            textField.heightAnchor.constraint(equalToConstant: 40),

            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 30),
            sendButton.heightAnchor.constraint(equalToConstant: 30),

            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor)
        ])
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        inputContainerBottomConstraint.constant = -keyboardHeight

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        inputContainerBottomConstraint.constant = 0

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func sendTapped() {
        sendMessage()
    }

    private func sendMessage() {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        textField.text = ""
        textField.resignFirstResponder()
        messages.append((role: "user", content: text, image: "user", isTyping: false))
        tableView.reloadData()
        scrollToBottom()

        // Show animated typing indicator
        messages.append((role: "assistant", content: "", image: "openai", isTyping: true))
        tableView.reloadData()
        scrollToBottom()

        LegacyAPI.shared.sendMessageToLivia(message: text) { [weak self] result in
            DispatchQueue.main.async {
                // Remove typing indicator
                self?.messages.removeLast()

                switch result {
                case .success(let response):
                    // Show full response directly
                    self?.messages.append((role: "assistant", content: response, image: "openai", isTyping: false))
                    self?.tableView.reloadData()
                    self?.scrollToBottom()
                case .failure(let error):
                    self?.messages.append((role: "assistant", content: "Sorry, I encountered an error: \(error.localizedDescription)", image: "openai", isTyping: false))
                    self?.tableView.reloadData()
                    self?.scrollToBottom()
                }
            }
        }
    }

    private func scrollToBottom() {
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

extension LegacyLiviaViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! LiviaChatMessageCell
        let message = messages[indexPath.row]
        cell.configure(role: message.role, content: message.content, imageName: message.image, isTyping: message.isTyping)
        return cell
    }
}

extension LegacyLiviaViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}

// Animated Typing Dots View
class TypingDotsView: UIView {
    private var dots: [UIView] = []
    private var animating = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDots()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDots()
    }

    private func setupDots() {
        let dotSize: CGFloat = 10
        let spacing: CGFloat = 6

        for i in 0..<3 {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.backgroundColor = .gray
            dot.layer.cornerRadius = dotSize / 2
            addSubview(dot)
            dots.append(dot)

            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: dotSize),
                dot.heightAnchor.constraint(equalToConstant: dotSize),
                dot.centerYAnchor.constraint(equalTo: centerYAnchor),
                dot.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CGFloat(i) * (dotSize + spacing))
            ])
        }

        // Set intrinsic content size
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 3 * dotSize + 2 * spacing),
            heightAnchor.constraint(equalToConstant: dotSize)
        ])
    }

    func startAnimating() {
        guard !animating else { return }
        animating = true
        animateDots()
    }

    func stopAnimating() {
        animating = false
        dots.forEach { $0.layer.removeAllAnimations() }
    }

    private func animateDots() {
        for (index, dot) in dots.enumerated() {
            let delay = Double(index) * 0.2
            UIView.animate(
                withDuration: 0.4,
                delay: delay,
                options: [.repeat, .autoreverse, .curveEaseInOut],
                animations: {
                    dot.transform = CGAffineTransform(translationX: 0, y: -6)
                    dot.alpha = 1.0
                },
                completion: nil
            )
        }
    }
}

// Chat Message Cell (Exact SwiftUI MessageRowView Layout)
class LiviaChatMessageCell: UITableViewCell {

    private lazy var containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()

    private lazy var blurView: UIVisualEffectView = {
        let blur: UIBlurEffect
        if #available(iOS 13.0, *) {
            blur = UIBlurEffect(style: .systemUltraThinMaterial)
        } else {
            blur = UIBlurEffect(style: .light)
        }
        let v = UIVisualEffectView(effect: blur)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var roleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 16)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        return label
    }()

    private lazy var typingDotsView: TypingDotsView = {
        let v = TypingDotsView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
        } else {
            backgroundColor = .white
        }
        contentView.backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubview(blurView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(roleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(typingDotsView)

        // Message label bottom constraint - this drives the cell height
        let messageLabelBottom = messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        messageLabelBottom.priority = .required

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            blurView.topAnchor.constraint(equalTo: containerView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),

            roleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            roleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),

            messageLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            messageLabelBottom,

            typingDotsView.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            typingDotsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Set preferredMaxLayoutWidth to ensure text wraps correctly
        let maxWidth = contentView.bounds.width - 32 - 32  // 16 padding on each side of container + 16 padding inside
        messageLabel.preferredMaxLayoutWidth = maxWidth
    }

    func configure(role: String, content: String, imageName: String, isTyping: Bool = false) {
        iconImageView.image = UIImage(named: imageName)

        if imageName == "openai" {
            roleLabel.text = "LIVIA"
        } else {
            roleLabel.text = imageName.uppercased()
        }

        if isTyping {
            messageLabel.isHidden = true
            typingDotsView.isHidden = false
            typingDotsView.startAnimating()
        } else {
            messageLabel.isHidden = false
            messageLabel.text = content
            typingDotsView.isHidden = true
            typingDotsView.stopAnimating()
        }

        // Force layout update for proper text wrapping
        setNeedsLayout()
        layoutIfNeeded()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        typingDotsView.stopAnimating()
        typingDotsView.isHidden = true
        messageLabel.isHidden = false
    }
}

// MARK: - Font Helpers

private func roundedPlanetFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
    let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
    if #available(iOS 13.0, *) {
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: size)
        }
    }
    return systemFont
}

private func serifPlanetFont(size: CGFloat) -> UIFont {
    if #available(iOS 13.0, *) {
        let systemFont = UIFont.systemFont(ofSize: size)
        if let descriptor = systemFont.fontDescriptor.withDesign(.serif) {
            return UIFont(descriptor: descriptor, size: size)
        }
    }
    return UIFont(name: "Georgia", size: size) ?? UIFont.systemFont(ofSize: size)
}
