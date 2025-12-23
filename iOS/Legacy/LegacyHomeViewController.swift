//
//  LegacyHomeViewController.swift
//  Cosmofy
//
//  Programmatic UIKit replica of Home.swift
//  Pixel-perfect match of the SwiftUI Home screen
//

import UIKit

// MARK: - Rounded Font Helper

private func roundedFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
    let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
    if #available(iOS 13.0, *) {
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: size)
        }
    }
    return systemFont
}

class LegacyHomeViewController: UIViewController {

    // MARK: - Properties

    private var firstName: String {
        return UserDefaults.standard.string(forKey: "firstName") ?? "individual"
    }

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = true
        sv.alwaysBounceVertical = true
        return sv
    }()

    private lazy var contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // "Begin your space journey"
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Begin your space journey"
        label.font = roundedFont(size: 17, weight: .regular)
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .gray
        }
        return label
    }()

    // "Hello [name]."
    private lazy var greetingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello \(firstName)."
        label.font = roundedFont(size: 34, weight: .bold)
        label.numberOfLines = 0

        // Gradient text
        if #available(iOS 13.0, *) {
            label.textColor = .label
            applyGradient(to: label)
        } else {
            label.textColor = .purple
        }

        return label
    }()

    // "What would you like to do today?"
    private lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "What would you like to do today?"
        label.font = roundedFont(size: 17, weight: .regular)
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .gray
        }
        return label
    }()

    // Navigation Cards
    private lazy var pictureOfTheDayCard: NavigationCardView = {
        let card = NavigationCardView(
            imageName: "home-icon-2",
            title: "Picture of the Day",
            subtitle: "View a new astronomy image every day"
        )
        card.translatesAutoresizingMaskIntoConstraints = false
        card.addTarget(self, action: #selector(pictureOfTheDayTapped), for: .touchUpInside)
        return card
    }()

    private lazy var articleOfTheMonthCard: NavigationCardView = {
        let card = NavigationCardView(
            imageName: "home-icon-1",
            title: "Article of the Month",
            subtitle: "Read a new space article every month"
        )
        card.translatesAutoresizingMaskIntoConstraints = false
        card.addTarget(self, action: #selector(articleOfTheMonthTapped), for: .touchUpInside)
        return card
    }()

    private lazy var natureScopeCard: NavigationCardView = {
        let card = NavigationCardView(
            imageName: "home-icon-4",
            title: "Nature Scope",
            subtitle: "View natural events and disasters around the globe"
        )
        card.translatesAutoresizingMaskIntoConstraints = false
        card.addTarget(self, action: #selector(natureScopeTapped), for: .touchUpInside)
        return card
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Update greeting in case name changed
        greetingLabel.text = "Hello \(firstName)."
        applyGradient(to: greetingLabel)
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "Cosmofy"
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.largeTitleTextAttributes = [
                .font: roundedFont(size: 34, weight: .bold)
            ]
            appearance.titleTextAttributes = [
                .font: roundedFont(size: 17, weight: .semibold)
            ]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
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

        contentView.addSubview(subtitleLabel)
        contentView.addSubview(greetingLabel)
        contentView.addSubview(questionLabel)
        contentView.addSubview(pictureOfTheDayCard)
        contentView.addSubview(articleOfTheMonthCard)
        contentView.addSubview(natureScopeCard)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Subtitle "Begin your space journey"
            subtitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Greeting "Hello [name]."
            greetingLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            greetingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            greetingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Question "What would you like to do today?"
            questionLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 4),
            questionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Picture of the Day Card
            pictureOfTheDayCard.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 32),
            pictureOfTheDayCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            pictureOfTheDayCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Article of the Month Card
            articleOfTheMonthCard.topAnchor.constraint(equalTo: pictureOfTheDayCard.bottomAnchor, constant: 12),
            articleOfTheMonthCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            articleOfTheMonthCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Nature Scope Card
            natureScopeCard.topAnchor.constraint(equalTo: articleOfTheMonthCard.bottomAnchor, constant: 12),
            natureScopeCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            natureScopeCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            natureScopeCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
        ])
    }

    // MARK: - Gradient Text

    private func applyGradient(to label: UILabel) {
        guard label.text != nil else { return }

        let gradientColors: [UIColor] = [
            UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0),    // Blue
            UIColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0),      // Purple
            UIColor(red: 1.0, green: 0.412, blue: 0.706, alpha: 1.0),  // Pink
            UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0),      // Orange
            UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)      // Yellow
        ]

        // Create gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        // Size the gradient to the label
        label.layoutIfNeeded()
        let size = label.intrinsicContentSize
        gradientLayer.frame = CGRect(origin: .zero, size: size)

        // Render gradient to image
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        gradientLayer.render(in: context)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // Apply as text color
        if let image = gradientImage {
            label.textColor = UIColor(patternImage: image)
        }
    }

    // MARK: - Actions

    @objc private func pictureOfTheDayTapped() {
        let pictureVC = LegacyPictureOfTheDayViewController()
        navigationController?.pushViewController(pictureVC, animated: true)
    }

    @objc private func articleOfTheMonthTapped() {
        let articleVC = LegacyArticleOfTheMonthViewController()
        navigationController?.pushViewController(articleVC, animated: true)
    }

    @objc private func natureScopeTapped() {
        let natureScopeVC = LegacyNatureScopeViewController()
        navigationController?.pushViewController(natureScopeVC, animated: true)
    }
}

// MARK: - Navigation Card View

class NavigationCardView: UIControl {

    // MARK: - UI Components

    private lazy var containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = false
        return v
    }()

    private lazy var iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        if let customFont = UIFont(name: "SFProRounded-Medium", size: 18) {
            label.font = customFont
        } else {
            label.font = roundedFont(size: 18, weight: .medium)
        }
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        if let customFont = UIFont(name: "SFProRounded-Medium", size: 18) {
            label.font = customFont
        } else {
            label.font = roundedFont(size: 18, weight: .medium)
        }
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .gray
        }
        label.numberOfLines = 0
        return label
    }()

    private lazy var chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        if #available(iOS 13.0, *) {
            iv.tintColor = .secondaryLabel
        } else {
            iv.tintColor = .gray
        }
        if #available(iOS 13.0, *) {
            iv.image = UIImage(systemName: "chevron.right")
        } else {
            iv.image = UIImage(named: "chevron-right")
        }
        return iv
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
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - Init

    init(imageName: String, title: String, subtitle: String) {
        super.init(frame: .zero)

        iconImageView.image = UIImage(named: imageName)
        titleLabel.text = title
        subtitleLabel.text = subtitle

        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        // Background blur
        addSubview(blurView)

        // Container
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(chevronImageView)

        // Rounded corners
        layer.cornerRadius = 24
        clipsToBounds = true
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Blur fills entire view
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Container with padding
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            // Icon
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),

            // Chevron
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20),

            // Title
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),

            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            subtitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }

    // MARK: - Touch Feedback

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.alpha = self.isHighlighted ? 0.7 : 1.0
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            }
        }
    }
}
