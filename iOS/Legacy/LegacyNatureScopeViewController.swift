//
//  LegacyNatureScopeViewController.swift
//  Cosmofy
//
//  Programmatic UIKit replica of NatureScope with MapKit
//

import UIKit
import MapKit

// MARK: - Nature Scope Categories (Local copy for iOS 9+ compatibility)

private struct NatureScopeCategory {
    let id: String
    let title: String
    let description: String
}

private let natureScopeCategories: [NatureScopeCategory] = [
    NatureScopeCategory(id: "1", title: "Drought", description: "Long lasting absence of precipitation affecting agriculture and livestock, and the overall availability of food and water."),
    NatureScopeCategory(id: "2", title: "Dust and Haze", description: "Related to dust storms, air pollution and other non-volcanic aerosols."),
    NatureScopeCategory(id: "3", title: "Earthquakes", description: "Related to all manner of shaking and displacement."),
    NatureScopeCategory(id: "4", title: "Floods", description: "Related to aspects of actual flooding--e.g., inundation, water extending beyond river and lake extents."),
    NatureScopeCategory(id: "5", title: "Landslides", description: "Related to landslides and variations thereof: mudslides, avalanche."),
    NatureScopeCategory(id: "6", title: "Manmade", description: "Events that have been human-induced and are extreme in their extent."),
    NatureScopeCategory(id: "7", title: "Sea and Lake Ice", description: "Related to all ice that resides on oceans and lakes."),
    NatureScopeCategory(id: "8", title: "Severe Storms", description: "Related to the atmospheric aspect of storms (hurricanes, cyclones, tornadoes, etc.)."),
    NatureScopeCategory(id: "9", title: "Snow", description: "Related to snow events, particularly extreme/anomalous snowfall."),
    NatureScopeCategory(id: "10", title: "Temperature Extremes", description: "Related to anomalous land temperatures, either heat or cold."),
    NatureScopeCategory(id: "11", title: "Volcanoes", description: "Related to both the physical effects of an eruption and the atmospheric (ash and gas plumes)."),
    NatureScopeCategory(id: "12", title: "Water Color", description: "Related to events that alter the appearance of water: phytoplankton, red tide, algae, sediment."),
    NatureScopeCategory(id: "13", title: "Wildfires", description: "Wildfires includes all nature of fire, including forest and plains fires.")
]

// MARK: - Nature Scope Info View Controller

class LegacyNatureScopeViewController: UIViewController {

    // MARK: - Properties

    private var events: [LegacyEvent] = []

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private lazy var contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // Header
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "FROM THE NASA EARTH OBSERVATORY"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .gray
        }
        return label
    }()

    private lazy var headerDivider: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            v.backgroundColor = .separator
        } else {
            v.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        }
        return v
    }()

    // Title
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "BROWSE THE ENTIRE EARTH FOR NATURAL EVENTS AND DISASTERS AS THEY OCCUR"
        label.numberOfLines = 0
        // Condensed font
        if #available(iOS 16.0, *) {
            label.font = UIFont.systemFont(ofSize: 42, weight: .bold, width: .compressed)
        } else if #available(iOS 13.0, *) {
            let baseFont = UIFont.systemFont(ofSize: 42, weight: .bold)
            if let descriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitCondensed) {
                label.font = UIFont(descriptor: descriptor, size: 42)
            } else {
                label.font = baseFont
            }
        } else {
            label.font = UIFont.systemFont(ofSize: 42, weight: .bold)
        }
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        return label
    }()

    // Date subtitle
    private lazy var dateSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Displaying all events since \(getFormattedDate14DaysAgoLegacy())"
        label.numberOfLines = 0
        // Italic serif
        let baseFont = serifNatureFont(size: 17)
        if let italicDescriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitItalic) {
            label.font = UIFont(descriptor: italicDescriptor, size: 17)
        } else {
            label.font = baseFont
        }
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .gray
        }
        return label
    }()

    // Enter button
    private lazy var enterButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Enter Nature Scope", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.2, green: 0.78, blue: 0.35, alpha: 1.0) // Green
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(enterMapTapped), for: .touchUpInside)
        return button
    }()

    // Categories header
    private lazy var categoriesHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "CURRENT CATEGORIES"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .gray
        }
        return label
    }()

    private lazy var categoriesDivider: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            v.backgroundColor = .separator
        } else {
            v.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        }
        return v
    }()

    // Categories stack
    private lazy var categoriesStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        setupCategories()
        fetchEvents()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "Nature Scope"
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }

    private func setupUI() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(headerLabel)
        contentView.addSubview(headerDivider)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateSubtitleLabel)
        contentView.addSubview(enterButton)
        contentView.addSubview(categoriesHeaderLabel)
        contentView.addSubview(categoriesDivider)
        contentView.addSubview(categoriesStack)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            headerDivider.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            headerDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            headerDivider.heightAnchor.constraint(equalToConstant: 0.5),

            titleLabel.topAnchor.constraint(equalTo: headerDivider.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            dateSubtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            dateSubtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateSubtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            enterButton.topAnchor.constraint(equalTo: dateSubtitleLabel.bottomAnchor, constant: 16),
            enterButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            enterButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            enterButton.heightAnchor.constraint(equalToConstant: 50),

            categoriesHeaderLabel.topAnchor.constraint(equalTo: enterButton.bottomAnchor, constant: 24),
            categoriesHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoriesHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            categoriesDivider.topAnchor.constraint(equalTo: categoriesHeaderLabel.bottomAnchor, constant: 8),
            categoriesDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoriesDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoriesDivider.heightAnchor.constraint(equalToConstant: 0.5),

            categoriesStack.topAnchor.constraint(equalTo: categoriesDivider.bottomAnchor, constant: 8),
            categoriesStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoriesStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoriesStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    private func setupCategories() {
        for category in natureScopeCategories {
            let categoryView = createCategoryView(category)
            categoriesStack.addArrangedSubview(categoryView)
        }
    }

    private func createCategoryView(_ category: NatureScopeCategory) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = category.title
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        if #available(iOS 13.0, *) {
            titleLabel.textColor = .label
        } else {
            titleLabel.textColor = .black
        }

        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = category.description
        descriptionLabel.font = serifNatureFont(size: 15)
        if #available(iOS 13.0, *) {
            descriptionLabel.textColor = .secondaryLabel
        } else {
            descriptionLabel.textColor = .gray
        }
        descriptionLabel.numberOfLines = 0
        // Make italic
        if let italicDescriptor = descriptionLabel.font.fontDescriptor.withSymbolicTraits(.traitItalic) {
            descriptionLabel.font = UIFont(descriptor: italicDescriptor, size: 15)
        }

        let idLabel = UILabel()
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        idLabel.text = category.id
        idLabel.font = serifNatureFont(size: 24)
        if #available(iOS 13.0, *) {
            idLabel.textColor = .label
        } else {
            idLabel.textColor = .black
        }
        idLabel.textAlignment = .center

        container.addSubview(idLabel)
        container.addSubview(titleLabel)
        container.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),

            idLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            idLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            idLabel.widthAnchor.constraint(equalToConstant: 45),

            titleLabel.leadingAnchor.constraint(equalTo: idLabel.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),

            descriptionLabel.leadingAnchor.constraint(equalTo: idLabel.trailingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])

        return container
    }

    // MARK: - Data Fetching

    private func fetchEvents() {
        LegacyAPI.shared.fetchEvents { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let events):
                    self?.events = events
                case .failure:
                    break // Silently fail, user can still enter map
                }
            }
        }
    }

    // MARK: - Actions

    @objc private func enterMapTapped() {
        let mapVC = LegacyNatureScopeMapViewController(events: events)
        navigationController?.pushViewController(mapVC, animated: true)
    }
}

// MARK: - Nature Scope Map View Controller

class LegacyNatureScopeMapViewController: UIViewController {

    // MARK: - Properties

    private var events: [LegacyEvent]
    private var selectedEvent: LegacyEvent?
    private var annotations: [EventAnnotation] = []

    // MARK: - UI Components

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            indicator = UIActivityIndicatorView(style: .large)
        } else {
            indicator = UIActivityIndicatorView(style: .gray)
        }
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()

    private lazy var mapView: MKMapView = {
        let mv = MKMapView()
        mv.translatesAutoresizingMaskIntoConstraints = false
        mv.delegate = self
        mv.showsCompass = true
        mv.showsScale = true
        if #available(iOS 16.0, *) {
            mv.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .realistic)
        }
        return mv
    }()

    private lazy var eventInfoView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true

        // Blur background
        let blur: UIBlurEffect
        if #available(iOS 13.0, *) {
            blur = UIBlurEffect(style: .systemUltraThinMaterial)
        } else {
            blur = UIBlurEffect(style: .light)
        }
        let blurView = UIVisualEffectView(effect: blur)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(blurView)
        v.layer.cornerRadius = 24
        v.clipsToBounds = true

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: v.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: v.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: v.bottomAnchor)
        ])

        return v
    }()

    private lazy var eventTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = roundedNatureFont(size: 18, weight: .medium)
        label.numberOfLines = 0
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        return label
    }()

    private lazy var eventCategoryIcon: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()

    private lazy var eventCategoryBackground: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 17.5
        v.clipsToBounds = true
        return v
    }()

    private lazy var eventCategoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = roundedNatureFont(size: 16, weight: .medium)
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        return label
    }()

    private lazy var eventDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = roundedNatureFont(size: 14, weight: .regular)
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .gray
        }
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            button.tintColor = .gray
        } else {
            button.setTitle("✕", for: .normal)
        }
        button.addTarget(self, action: #selector(closeInfoView), for: .touchUpInside)
        return button
    }()

    // MARK: - Init

    init(events: [LegacyEvent]) {
        self.events = events
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()

        // If events were passed, add them immediately. Otherwise fetch.
        if events.isEmpty {
            fetchEventsForMap()
        } else {
            addEventAnnotations()
        }
    }

    private func fetchEventsForMap() {
        loadingIndicator.startAnimating()
        LegacyAPI.shared.fetchEvents { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                switch result {
                case .success(let events):
                    self?.events = events
                    self?.addEventAnnotations()
                case .failure(let error):
                    print("Failed to fetch events: \(error)")
                }
            }
        }
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "Map"
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }

    private func setupUI() {
        view.addSubview(mapView)
        view.addSubview(loadingIndicator)
        view.addSubview(eventInfoView)

        eventInfoView.addSubview(closeButton)
        eventInfoView.addSubview(eventTitleLabel)
        eventInfoView.addSubview(eventCategoryBackground)
        eventCategoryBackground.addSubview(eventCategoryIcon)
        eventInfoView.addSubview(eventCategoryLabel)
        eventInfoView.addSubview(eventDateLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            eventInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            eventInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            eventInfoView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -16),
            eventInfoView.heightAnchor.constraint(equalToConstant: 140),

            closeButton.topAnchor.constraint(equalTo: eventInfoView.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: eventInfoView.trailingAnchor, constant: -12),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            eventTitleLabel.topAnchor.constraint(equalTo: eventInfoView.topAnchor, constant: 16),
            eventTitleLabel.leadingAnchor.constraint(equalTo: eventInfoView.leadingAnchor, constant: 16),
            eventTitleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),

            eventCategoryBackground.topAnchor.constraint(equalTo: eventTitleLabel.bottomAnchor, constant: 12),
            eventCategoryBackground.leadingAnchor.constraint(equalTo: eventInfoView.leadingAnchor, constant: 16),
            eventCategoryBackground.widthAnchor.constraint(equalToConstant: 35),
            eventCategoryBackground.heightAnchor.constraint(equalToConstant: 35),

            eventCategoryIcon.centerXAnchor.constraint(equalTo: eventCategoryBackground.centerXAnchor),
            eventCategoryIcon.centerYAnchor.constraint(equalTo: eventCategoryBackground.centerYAnchor),
            eventCategoryIcon.widthAnchor.constraint(equalToConstant: 20),
            eventCategoryIcon.heightAnchor.constraint(equalToConstant: 20),

            eventCategoryLabel.centerYAnchor.constraint(equalTo: eventCategoryBackground.centerYAnchor),
            eventCategoryLabel.leadingAnchor.constraint(equalTo: eventCategoryBackground.trailingAnchor, constant: 12),

            eventDateLabel.topAnchor.constraint(equalTo: eventCategoryBackground.bottomAnchor, constant: 8),
            eventDateLabel.leadingAnchor.constraint(equalTo: eventInfoView.leadingAnchor, constant: 16)
        ])
    }

    private func addEventAnnotations() {
        for event in events {
            guard let geometry = event.geometry?.last,
                  let coordinates = geometry.coordinates,
                  coordinates.count >= 2 else { continue }

            let lat = coordinates[1]
            let lon = coordinates[0]

            let annotation = EventAnnotation(event: event)
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            annotation.title = event.title
            annotations.append(annotation)
            mapView.addAnnotation(annotation)
        }
    }

    // MARK: - Actions

    @objc private func closeInfoView() {
        UIView.animate(withDuration: 0.3) {
            self.eventInfoView.isHidden = true
        }
        selectedEvent = nil

        // Deselect annotation
        for annotation in mapView.selectedAnnotations {
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }

    private func showEventInfo(_ event: LegacyEvent) {
        selectedEvent = event
        eventTitleLabel.text = event.title

        // Category
        if let category = event.categories?.first {
            eventCategoryLabel.text = category.title
            let color = markerColorLegacy(for: category.id)
            eventCategoryBackground.backgroundColor = color

            if #available(iOS 13.0, *) {
                eventCategoryIcon.image = UIImage(systemName: markerImageLegacy(for: category.id))
                // Adjust icon color for light backgrounds
                if color == .white || color == UIColor.yellow {
                    eventCategoryIcon.tintColor = .black
                } else {
                    eventCategoryIcon.tintColor = .white
                }
            }
        }

        // Date
        if let date = event.geometry?.first?.date {
            eventDateLabel.text = formatEventDate(date)
        }

        eventInfoView.isHidden = false
    }

    private func formatEventDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .long
        outputFormatter.timeStyle = .short

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return "Unknown Date"
    }
}

// MARK: - MKMapViewDelegate

extension LegacyNatureScopeMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let eventAnnotation = annotation as? EventAnnotation else { return nil }

        let identifier = "EventMarker"

        if #available(iOS 11.0, *) {
            var view: MKMarkerAnnotationView

            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
                view = dequeuedView
                view.annotation = annotation
            } else {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }

            let categoryId = eventAnnotation.event.categories?.first?.id ?? ""
            view.markerTintColor = markerColorLegacy(for: categoryId)

            if #available(iOS 13.0, *) {
                view.glyphImage = UIImage(systemName: markerImageLegacy(for: categoryId))
            }

            return view
        } else {
            // Fallback for older iOS
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                pinView?.canShowCallout = true
            } else {
                pinView?.annotation = annotation
            }
            return pinView
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let eventAnnotation = view.annotation as? EventAnnotation else { return }
        showEventInfo(eventAnnotation.event)
    }
}

// MARK: - Event Annotation

class EventAnnotation: MKPointAnnotation {
    let event: LegacyEvent

    init(event: LegacyEvent) {
        self.event = event
        super.init()
    }
}

// MARK: - Helper Functions

private func getFormattedDate14DaysAgoLegacy() -> String {
    let currentDate = Date()
    guard let date14DaysAgo = Calendar.current.date(byAdding: .day, value: -15, to: currentDate) else {
        return "Date calculation error"
    }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM d"
    return dateFormatter.string(from: date14DaysAgo)
}

private func markerImageLegacy(for categoryId: String) -> String {
    switch categoryId.lowercased() {
    case "drought", "1":
        return "drop.circle"
    case "dusthaze", "2":
        return "sun.haze"
    case "earthquakes", "3":
        return "waveform.path.ecg"
    case "floods", "4":
        return "cloud.rain"
    case "landslides", "5":
        return "arrowtriangle.down.circle"
    case "manmade", "6":
        return "hammer"
    case "sealakeice", "7":
        return "snowflake"
    case "severestorms", "8":
        return "cloud.bolt.rain"
    case "snow", "9":
        return "snowflake"
    case "tempextremes", "10":
        return "thermometer.snowflake"
    case "volcanoes", "11":
        return "mountain.2"
    case "watercolor", "12":
        return "drop.triangle.fill"
    case "wildfires", "13":
        return "flame"
    default:
        return "mappin.circle"
    }
}

private func markerColorLegacy(for categoryId: String) -> UIColor {
    switch categoryId.lowercased() {
    case "drought", "1":
        return .systemYellow
    case "dusthaze", "2":
        return .systemGreen
    case "earthquakes", "3":
        return .systemGray
    case "floods", "4":
        return .systemBlue
    case "landslides", "5":
        return .systemOrange
    case "manmade", "6":
        return .systemPurple
    case "sealakeice", "7":
        return .white
    case "severestorms", "8":
        if #available(iOS 15.0, *) {
            return .systemMint
        } else {
            return .systemTeal
        }
    case "snow", "9":
        return .white
    case "tempextremes", "10":
        if #available(iOS 15.0, *) {
            return .systemCyan
        } else {
            return .cyan
        }
    case "volcanoes", "11":
        return .systemRed
    case "watercolor", "12":
        return .black
    case "wildfires", "13":
        return .systemOrange
    default:
        return .systemYellow
    }
}

private func serifNatureFont(size: CGFloat) -> UIFont {
    if #available(iOS 13.0, *) {
        let systemFont = UIFont.systemFont(ofSize: size)
        if let descriptor = systemFont.fontDescriptor.withDesign(.serif) {
            return UIFont(descriptor: descriptor, size: size)
        }
    }
    return UIFont(name: "Georgia", size: size) ?? UIFont.systemFont(ofSize: size)
}

private func roundedNatureFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
    let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
    if #available(iOS 13.0, *) {
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: size)
        }
    }
    return systemFont
}
