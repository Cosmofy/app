//
//  LegacyViewController.swift
//  Cosmofy
//
//  Legacy view controller for iOS 9-16
//

import UIKit

class LegacyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.white

        // Create a container view for centering
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        // App icon image
        let imageView = UIImageView()
        imageView.image = UIImage(named: "app-icon-4k")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "Cosmofy"
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        // Subtitle label
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Explore the Solar System"
        subtitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        subtitleLabel.textColor = UIColor.gray
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(subtitleLabel)

        // Update message
        let updateLabel = UILabel()
        updateLabel.text = "This version of Cosmofy requires iOS 17 or later for the full experience."
        updateLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        updateLabel.textColor = UIColor.darkGray
        updateLabel.textAlignment = .center
        updateLabel.numberOfLines = 0
        updateLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(updateLabel)

        // Update button
        let updateButton = UIButton(type: .system)
        updateButton.setTitle("Update iOS in Settings", for: .normal)
        updateButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        updateButton.backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
        updateButton.setTitleColor(.white, for: .normal)
        updateButton.layer.cornerRadius = 12
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        updateButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        containerView.addSubview(updateButton)

        // Layout constraints
        NSLayoutConstraint.activate([
            // Container view
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),

            // Image view
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),

            // Title label
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

            // Subtitle label
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

            // Update label
            updateLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            updateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            updateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

            // Update button
            updateButton.topAnchor.constraint(equalTo: updateLabel.bottomAnchor, constant: 24),
            updateButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            updateButton.widthAnchor.constraint(equalToConstant: 250),
            updateButton.heightAnchor.constraint(equalToConstant: 50),
            updateButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }

    @objc private func openSettings() {
        if let settingsURL = URL(string: "App-prefs:root=General&path=SOFTWARE_UPDATE_LINK") {
            if UIApplication.shared.canOpenURL(settingsURL) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(settingsURL)
                }
            } else if let generalURL = URL(string: "App-prefs:root=General") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(generalURL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(generalURL)
                }
            }
        }
    }
}
