//
//  LegacyPictureOfTheDayViewController.swift
//  Cosmofy
//
//  Programmatic UIKit replica of IOTDView (Picture of the Day)
//

import UIKit
import WebKit

// MARK: - Rounded Font Helper (if not already available)

private func legacyRoundedFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
    let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
    if #available(iOS 13.0, *) {
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: size)
        }
    }
    return systemFont
}

private func serifFont(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
    if #available(iOS 13.0, *) {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        if let descriptor = systemFont.fontDescriptor.withDesign(.serif) {
            return UIFont(descriptor: descriptor, size: size)
        }
    }
    return UIFont(name: "Georgia", size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
}

class LegacyPictureOfTheDayViewController: UIViewController {

    // MARK: - Properties

    private var picture: LegacyPicture?
    private var loadedImage: UIImage?
    private var isLoading = false
    private var currentSelectedDate: Date = Date()

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

    // Header: "ASTRONOMY PICTURE OF THE DAY"
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "ASTRONOMY PICTURE OF THE DAY"
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

    // Title (large, condensed/compressed)
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        // Use condensed width font
        if #available(iOS 16.0, *) {
            label.font = UIFont.systemFont(ofSize: 42, weight: .bold, width: .compressed)
        } else if #available(iOS 13.0, *) {
            // Fallback: try to get condensed trait
            let baseFont = UIFont.systemFont(ofSize: 42, weight: .bold)
            if let descriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitCondensed) {
                label.font = UIFont(descriptor: descriptor, size: 42)
            } else {
                label.font = baseFont
            }
        } else {
            label.font = UIFont.systemFont(ofSize: 42, weight: .bold)
        }
        label.numberOfLines = 0
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        return label
    }()

    // Date (italic serif)
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        // Make it italic serif
        let baseFont = serifFont(size: 17)
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

    // Image View
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        return iv
    }()

    // Image height constraint (will be updated based on aspect ratio)
    private var imageHeightConstraint: NSLayoutConstraint?

    // Video WebView for YouTube embeds
    private lazy var videoWebView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            config.mediaTypesRequiringUserActionForPlayback = []
        }
        if #available(iOS 14.0, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        if #available(iOS 15.4, *) {
            config.preferences.isElementFullscreenEnabled = true
        }
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.isHidden = true
        return webView
    }()

    private var videoWebViewHeightConstraint: NSLayoutConstraint?

    // Download Button
    private lazy var downloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Download", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = legacyRoundedFont(size: 17, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 1.0) // Indigo
        button.layer.cornerRadius = 16
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(weight: .medium)
            let image = UIImage(systemName: "arrow.down.to.line", withConfiguration: config)
            button.setImage(image, for: .normal)
            button.tintColor = .white
            button.semanticContentAttribute = .forceRightToLeft
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        }
        button.addTarget(self, action: #selector(downloadTapped), for: .touchUpInside)
        return button
    }()

    // Share Button
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        button.layer.cornerRadius = 16
        if #available(iOS 13.0, *) {
            button.tintColor = .secondaryLabel
        } else {
            button.tintColor = .gray
        }
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(weight: .medium)
            button.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: config), for: .normal)
        }
        button.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        return button
    }()

    // Explanation Header
    private lazy var explanationHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "A BRIEF EXPLANATION"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .gray
        }
        return label
    }()

    private lazy var explanationDivider: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            v.backgroundColor = .separator
        } else {
            v.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        }
        return v
    }()

    // Explanation Text
    private lazy var explanationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = serifFont(size: 17)
        label.numberOfLines = 0
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        return label
    }()

    // Summary Header
    private lazy var summaryHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "SUMMARY"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .gray
        }
        label.isHidden = true
        return label
    }()

    private lazy var summaryDivider: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            v.backgroundColor = .separator
        } else {
            v.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        }
        v.isHidden = true
        return v
    }()

    // Summary Text
    private lazy var summaryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = serifFont(size: 17)
        label.numberOfLines = 0
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        label.isHidden = true
        return label
    }()

    // Copyright
    private lazy var copyrightLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .gray
        }
        label.isHidden = true
        return label
    }()

    // Stack to hold buttons
    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [downloadButton, shareButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        fetchPictureOfTheDay()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "Picture of the Day"
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }

        // Date picker button (simplified for legacy - just show today's date)
        if #available(iOS 13.0, *) {
            let calendarButton = UIBarButtonItem(
                image: UIImage(systemName: "calendar"),
                style: .plain,
                target: self,
                action: #selector(showDatePicker)
            )
            navigationItem.rightBarButtonItem = calendarButton
        }
    }

    private func setupUI() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)
        scrollView.addSubview(contentView)

        contentView.addSubview(headerLabel)
        contentView.addSubview(headerDivider)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(imageView)
        contentView.addSubview(videoWebView)
        contentView.addSubview(buttonStack)
        contentView.addSubview(explanationHeaderLabel)
        contentView.addSubview(explanationDivider)
        contentView.addSubview(explanationLabel)
        contentView.addSubview(summaryHeaderLabel)
        contentView.addSubview(summaryDivider)
        contentView.addSubview(summaryLabel)
        contentView.addSubview(copyrightLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Loading indicator centered
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

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

            // Header
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            headerDivider.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 4),
            headerDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            headerDivider.heightAnchor.constraint(equalToConstant: 0.5),

            // Title
            titleLabel.topAnchor.constraint(equalTo: headerDivider.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Date
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Image
            imageView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Video WebView (same position as image, but hidden by default)
            videoWebView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            videoWebView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            videoWebView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Button Stack
            buttonStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 50),

            downloadButton.heightAnchor.constraint(equalToConstant: 50),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50),

            // Explanation Header
            explanationHeaderLabel.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 24),
            explanationHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            explanationHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            explanationDivider.topAnchor.constraint(equalTo: explanationHeaderLabel.bottomAnchor, constant: 4),
            explanationDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            explanationDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            explanationDivider.heightAnchor.constraint(equalToConstant: 0.5),

            // Explanation Text
            explanationLabel.topAnchor.constraint(equalTo: explanationDivider.bottomAnchor, constant: 8),
            explanationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            explanationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Summary Header
            summaryHeaderLabel.topAnchor.constraint(equalTo: explanationLabel.bottomAnchor, constant: 24),
            summaryHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            summaryHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            summaryDivider.topAnchor.constraint(equalTo: summaryHeaderLabel.bottomAnchor, constant: 4),
            summaryDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            summaryDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            summaryDivider.heightAnchor.constraint(equalToConstant: 0.5),

            // Summary Text
            summaryLabel.topAnchor.constraint(equalTo: summaryDivider.bottomAnchor, constant: 8),
            summaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            summaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Copyright
            copyrightLabel.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 16),
            copyrightLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            copyrightLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            copyrightLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
        ])

        // Default image height (will be updated when image loads)
        imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 250)
        imageHeightConstraint?.isActive = true

        // Video height constraint (16:9 aspect ratio)
        let videoWidth = UIScreen.main.bounds.width - 32
        videoWebViewHeightConstraint = videoWebView.heightAnchor.constraint(equalToConstant: videoWidth * 9 / 16)
        videoWebViewHeightConstraint?.isActive = true
    }

    // MARK: - Data Loading

    private func fetchPictureOfTheDay(date: String? = nil) {
        isLoading = true
        scrollView.isHidden = true
        loadingIndicator.startAnimating()

        LegacyAPI.shared.fetchPictureOfTheDay(date: date) { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                self?.scrollView.isHidden = false
                self?.isLoading = false

                switch result {
                case .success(let picture):
                    self?.picture = picture
                    self?.updateUI(with: picture)
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }

    private func updateUI(with picture: LegacyPicture) {
        titleLabel.text = picture.title ?? "Untitled"
        dateLabel.text = formatDate(picture.date)

        // Load image or video
        if let mediaUrl = picture.media, picture.media_type == "image" {
            loadImage(from: mediaUrl)
            imageView.isHidden = false
            videoWebView.isHidden = true
            downloadButton.isEnabled = true
            shareButton.isEnabled = true
        } else if picture.media_type == "video", let videoUrl = picture.media {
            // Show video player with YouTube fix
            imageView.isHidden = true
            videoWebView.isHidden = false
            downloadButton.isEnabled = false
            shareButton.isEnabled = false
            downloadButton.alpha = 0.5
            shareButton.alpha = 0.5
            loadVideo(from: videoUrl)
        }

        // Explanation
        if let explanation = picture.explanation?.original, !explanation.isEmpty {
            // Make it italic
            let italicFont = serifFont(size: 17)
            if let descriptor = italicFont.fontDescriptor.withSymbolicTraits(.traitItalic) {
                explanationLabel.font = UIFont(descriptor: descriptor, size: 17)
            }
            explanationLabel.text = explanation
        }

        // Summary
        if let summary = picture.explanation?.summarized, !summary.isEmpty {
            summaryHeaderLabel.isHidden = false
            summaryDivider.isHidden = false
            summaryLabel.isHidden = false
            summaryLabel.text = summary
        }

        // Copyright
        if let copyright = picture.copyright, !copyright.isEmpty {
            copyrightLabel.isHidden = false
            copyrightLabel.text = "© \(copyright)"
        }
    }

    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                self?.loadedImage = image
                self?.imageView.image = image

                // Update height based on aspect ratio
                let aspectRatio = image.size.height / image.size.width
                let width = (self?.view.bounds.width ?? 375) - 32 // minus padding
                let height = width * aspectRatio
                self?.imageHeightConstraint?.constant = min(height, 500) // cap at 500

                UIView.animate(withDuration: 0.2) {
                    self?.view.layoutIfNeeded()
                }
            }
        }
        task.resume()
    }

    private func loadVideo(from urlString: String) {
        // Handle YouTube embeds with nocookie domain for better compatibility
        if urlString.contains("youtube.com/embed") {
            // Extract video ID and build nocookie URL
            let videoId = urlString
                .replacingOccurrences(of: "https://www.youtube.com/embed/", with: "")
                .components(separatedBy: "?").first ?? ""

            let src = "https://www.youtube-nocookie.com/embed/\(videoId)?playsinline=1&modestbranding=1&rel=0&enablejsapi=1&origin=https://www.youtube-nocookie.com"

            let html = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
                <style>
                    * { margin: 0; padding: 0; }
                    html, body { width: 100%; height: 100%; background: black; }
                    iframe { width: 100%; height: 100%; border: none; }
                </style>
            </head>
            <body>
                <iframe
                    src="\(src)"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; fullscreen"
                    allowfullscreen
                    webkitallowfullscreen
                    mozallowfullscreen>
                </iframe>
            </body>
            </html>
            """
            videoWebView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube-nocookie.com"))
        } else if let url = URL(string: urlString) {
            // For non-YouTube URLs, load directly
            videoWebView.load(URLRequest(url: url))
        }
    }

    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "" }

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = inputFormatter.date(from: dateString) else { return dateString }

        let outputFormatter = DateFormatter()
        // Include day name: "Sunday, December 8, 2025"
        outputFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        outputFormatter.locale = Locale.current

        return outputFormatter.string(from: date)
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.fetchPictureOfTheDay()
        })
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Actions

    @objc private func downloadTapped() {
        guard let image = loadedImage else { return }

        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)

        // Update button appearance
        downloadButton.setTitle("Saved to Gallery", for: .normal)
        downloadButton.backgroundColor = UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0) // Green
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(weight: .medium)
            downloadButton.setImage(UIImage(systemName: "checkmark.seal.fill", withConfiguration: config), for: .normal)
        }

        // Reset after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.downloadButton.setTitle("Download", for: .normal)
            self?.downloadButton.backgroundColor = UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 1.0)
            if #available(iOS 13.0, *) {
                let config = UIImage.SymbolConfiguration(weight: .medium)
                self?.downloadButton.setImage(UIImage(systemName: "arrow.down.to.line", withConfiguration: config), for: .normal)
            }
        }
    }

    @objc private func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let alert = UIAlertController(title: "Save Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    @objc private func shareTapped() {
        guard let image = loadedImage else { return }

        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = shareButton
        present(activityVC, animated: true)
    }

    @objc private func showDatePicker() {
        let alert = UIAlertController(title: "Select Date\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)

        // Use Mountain Time (America/Denver) for all date calculations
        let mountainTimeZone = TimeZone(identifier: "America/Denver")!

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.timeZone = mountainTimeZone

        // Calculate today's date in Mountain Time to set as maximum
        let calendar = Calendar.current
        var calendarMT = calendar
        calendarMT.timeZone = mountainTimeZone
        let nowInMT = Date()
        let componentsToday = calendarMT.dateComponents([.year, .month, .day], from: nowInMT)
        if let todayMT = calendarMT.date(from: componentsToday) {
            datePicker.maximumDate = todayMT
        }

        datePicker.date = currentSelectedDate  // Restore previously selected date

        // Use wheels style to show day, month, and year
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = mountainTimeZone

        if let minDate = formatter.date(from: "1995-06-16") {
            datePicker.minimumDate = minDate
        }

        // Position the date picker in the alert
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(datePicker)

        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
            datePicker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 8),
            datePicker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -8),
            datePicker.heightAnchor.constraint(equalToConstant: 180)
        ])

        // Set alert view height
        let heightConstraint = alert.view.heightAnchor.constraint(equalToConstant: 320)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true

        alert.addAction(UIAlertAction(title: "Select", style: .default) { [weak self] _ in
            self?.currentSelectedDate = datePicker.date  // Store selected date
            let selectedDate = formatter.string(from: datePicker.date)
            self?.fetchPictureOfTheDay(date: selectedDate)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }

        present(alert, animated: true)
    }
}
