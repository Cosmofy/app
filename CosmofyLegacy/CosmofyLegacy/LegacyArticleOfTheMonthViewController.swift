//
//  LegacyArticleOfTheMonthViewController.swift
//  Cosmofy
//
//  Programmatic UIKit replica of ArticleView
//

import UIKit
import WebKit

class LegacyArticleOfTheMonthViewController: UIViewController {

    // MARK: - Properties

    private var articles: [LegacyArticle] = []
    private var isLoading = false

    // MARK: - UI Components

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(ArticleCell.self, forCellWithReuseIdentifier: "ArticleCell")
        if #available(iOS 13.0, *) {
            cv.backgroundColor = .systemBackground
        } else {
            cv.backgroundColor = .white
        }
        cv.alwaysBounceVertical = true
        return cv
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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        fetchArticles()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "Articles"
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupUI() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Data Fetching

    private func fetchArticles() {
        isLoading = true
        loadingIndicator.startAnimating()
        collectionView.isHidden = true

        LegacyAPI.shared.fetchArticles { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.loadingIndicator.stopAnimating()
                self?.collectionView.isHidden = false

                switch result {
                case .success(let articles):
                    // Sort by year and month (newest first)
                    self?.articles = articles.sorted { a, b in
                        let yearA = a.year ?? 0
                        let yearB = b.year ?? 0
                        if yearA != yearB { return yearA > yearB }
                        return (a.month ?? 0) > (b.month ?? 0)
                    }
                    self?.collectionView.reloadData()
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.fetchArticles()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension LegacyArticleOfTheMonthViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
        cell.configure(with: articles[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension LegacyArticleOfTheMonthViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let article = articles[indexPath.item]
        guard let urlString = article.url, let url = URL(string: urlString) else { return }

        let webVC = LegacyWebViewController(url: url, title: "Article of the Month")
        navigationController?.pushViewController(webVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension LegacyArticleOfTheMonthViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16 * 2
        let spacing: CGFloat = 16

        // Use 2 columns on iPad, 1 on iPhone
        let isRegular = traitCollection.horizontalSizeClass == .regular
        let columns: CGFloat = isRegular ? 2 : 1
        let availableWidth = collectionView.bounds.width - padding - (spacing * (columns - 1))
        let cellWidth = availableWidth / columns

        // Height: image (180 or 140) + info section (~80)
        let imageHeight: CGFloat = isRegular ? 140 : 180
        return CGSize(width: cellWidth, height: imageHeight + 80)
    }
}

// MARK: - Article Cell

class ArticleCell: UICollectionViewCell {

    private lazy var bannerImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        return iv
    }()

    private lazy var infoContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        return v
    }()

    // VStack for month/year
    private lazy var dateStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 0
        return stack
    }()

    private lazy var monthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = serifArticleFont(size: 28) // .largeTitle equivalent
        label.textAlignment = .center
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        return label
    }()

    private lazy var yearLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = serifArticleFont(size: 14) // .body equivalent
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    // VStack for title/authors
    private lazy var textStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 4
        return stack
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = roundedArticleFont(size: 16, weight: .medium)
        label.numberOfLines = 2
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        return label
    }()

    private lazy var authorsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        // Italic serif
        let baseFont = serifArticleFont(size: 12)
        if let italicDescriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitItalic) {
            label.font = UIFont(descriptor: italicDescriptor, size: 12)
        } else {
            label.font = baseFont
        }
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.layer.cornerRadius = 18
        contentView.clipsToBounds = true

        // Build hierarchy
        contentView.addSubview(bannerImageView)
        contentView.addSubview(infoContainer)

        // Date VStack: month above year
        dateStackView.addArrangedSubview(monthLabel)
        dateStackView.addArrangedSubview(yearLabel)
        infoContainer.addSubview(dateStackView)

        // Text VStack: title above authors
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(authorsLabel)
        infoContainer.addSubview(textStackView)

        NSLayoutConstraint.activate([
            // Banner image fills top
            bannerImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bannerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            // Info container at bottom
            infoContainer.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor),
            infoContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            infoContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            infoContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            infoContainer.heightAnchor.constraint(equalToConstant: 80),

            // Date stack (month/year VStack) - centered vertically, left aligned
            dateStackView.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor, constant: 16),
            dateStackView.centerYAnchor.constraint(equalTo: infoContainer.centerYAnchor),

            // Text stack (title/authors VStack) - after date stack with padding
            textStackView.leadingAnchor.constraint(equalTo: dateStackView.trailingAnchor, constant: 16),
            textStackView.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor, constant: -16),
            textStackView.centerYAnchor.constraint(equalTo: infoContainer.centerYAnchor)
        ])
    }

    func configure(with article: LegacyArticle) {
        monthLabel.text = String(format: "%02d", article.month ?? 0)
        yearLabel.text = String(article.year ?? 2024)
        titleLabel.text = article.title ?? "Untitled"

        if let authors = article.authors, !authors.isEmpty {
            authorsLabel.text = authors.compactMap { $0.name }.joined(separator: ", ")
        } else {
            authorsLabel.text = nil
        }

        // Load banner image
        bannerImageView.image = nil
        if let bannerUrl = article.banner?.image, let url = URL(string: bannerUrl) {
            loadImage(from: url)
        }
    }

    private func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.bannerImageView.image = image
            }
        }
        task.resume()
    }
}

// MARK: - Font Helpers

private func serifArticleFont(size: CGFloat) -> UIFont {
    if #available(iOS 13.0, *) {
        let systemFont = UIFont.systemFont(ofSize: size)
        if let descriptor = systemFont.fontDescriptor.withDesign(.serif) {
            return UIFont(descriptor: descriptor, size: size)
        }
    }
    return UIFont(name: "Georgia", size: size) ?? UIFont.systemFont(ofSize: size)
}

private func roundedArticleFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
    let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
    if #available(iOS 13.0, *) {
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: size)
        }
    }
    return systemFont
}

// MARK: - Legacy Web View Controller

class LegacyWebViewController: UIViewController {

    private let url: URL
    private let pageTitle: String

    private lazy var webView: WKWebView = {
        let wv = WKWebView()
        wv.translatesAutoresizingMaskIntoConstraints = false
        wv.navigationDelegate = self
        return wv
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

    init(url: URL, title: String) {
        self.url = url
        self.pageTitle = title
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPage()
    }

    private func setupUI() {
        title = pageTitle
        navigationItem.largeTitleDisplayMode = .never

        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        view.addSubview(webView)
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // Share button
        if #available(iOS 13.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "square.and.arrow.up"),
                style: .plain,
                target: self,
                action: #selector(shareTapped)
            )
        }
    }

    private func loadPage() {
        loadingIndicator.startAnimating()
        webView.load(URLRequest(url: url))
    }

    @objc private func shareTapped() {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityVC, animated: true)
    }
}

extension LegacyWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
    }
}
