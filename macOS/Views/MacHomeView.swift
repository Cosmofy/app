//
//  MacHomeView.swift
//  Cosmofy macOS
//
//  Created by Arryan Bhatnagar on 12/4/24.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers
import WebKit

// MARK: - Picture of the Day
struct MacIOTDView: View {
    @ObservedObject var viewModel: GQLViewModel
    @State private var selectedDate = Date()
    @State private var isLoading = false
    @State private var showingDatePicker = false

    private var mountainTimeZone: TimeZone {
        TimeZone(identifier: "America/Denver")!
    }

    private var todayInMountainTime: Date {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents(in: mountainTimeZone, from: now)
        components.hour = 12
        components.minute = 0
        components.second = 0
        return calendar.date(from: components) ?? now
    }

    var dateRange: ClosedRange<Date> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = mountainTimeZone
        return formatter.date(from: "1995-06-16")!...todayInMountainTime
    }

    private var canGoNext: Bool {
        let calendar = Calendar.current
        let nextDay = calendar.date(byAdding: .day, value: 1, to: selectedDate)!
        return nextDay <= todayInMountainTime
    }

    private var formattedDate: String {
        if let dateString = viewModel.picture?.date {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd"
            if let date = inputFormatter.date(from: dateString) {
                let outputFormatter = DateFormatter()
                outputFormatter.dateStyle = .long
                return outputFormatter.string(from: date)
            }
        }
        return "Loading..."
    }

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, minHeight: 400)
            } else if let picture = viewModel.picture {
                VStack(alignment: .leading, spacing: 20) {
                    // Title and Credits
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image("home-icon-2")
                                .resizable()
                                .frame(width: 32, height: 32)

                            Text(picture.title ?? "Picture of the Day")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .fontWidth(.compressed)
                        }

                        if let credit = picture.credit, !credit.isEmpty {
                            Text("Credit: \(credit)")
                                .font(.title3)
                                .fontDesign(.monospaced)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Image on left, text on right
                    HStack(alignment: .top, spacing: 32) {
                        // Image
                        VStack {
                            if picture.media_type == "video" {
                                if let url = picture.media, let videoURL = URL(string: url) {
                                    Link(destination: videoURL) {
                                        VStack {
                                            Image(systemName: "play.circle.fill")
                                                .font(.system(size: 48))
                                            Text("Watch Video")
                                        }
                                        .frame(width: 500, height: 350)
                                        .background(.quaternary)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            } else if let preloadedImage = viewModel.preloadedAPODImage {
                                Image(nsImage: preloadedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 600)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                if let copyright = picture.copyright, !copyright.isEmpty {
                                    Text("© \(copyright)")
                                        .font(.title2)
                                        .fontDesign(.monospaced)
                                        .foregroundStyle(.tertiary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, 4)
                                }
                            } else if let mediaUrl = picture.media, let url = URL(string: mediaUrl) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 600)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 500, height: 350)
                                }

                                if let copyright = picture.copyright, !copyright.isEmpty {
                                    Text("© \(copyright)")
                                        .font(.title2)
                                        .fontDesign(.monospaced)
                                        .foregroundStyle(.tertiary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, 4)
                                }
                            }
                        }

                        // Text
                        VStack(alignment: .leading, spacing: 20) {
                            if let explanation = picture.explanation {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Explanation")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)

                                    Text(explanation.original ?? "")
                                        .font(.system(size: 16))
                                        .fontDesign(.serif)
                                        .textSelection(.enabled)
                                        .lineSpacing(6)
                                }

                                if let summarized = explanation.summarized, !summarized.isEmpty {
                                    Divider()

                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Summary")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.secondary)

                                        Text(summarized)
                                            .font(.system(size: 16))
                                            .fontDesign(.serif)
                                            .textSelection(.enabled)
                                            .lineSpacing(6)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            } else {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, minHeight: 400)
            }
        }
        .navigationTitle(viewModel.picture?.title ?? "Picture of the Day")
        .navigationSubtitle(convertDateString(dateString: viewModel.picture?.date ?? ""))
    }

    private func goToPreviousDay() {
        let calendar = Calendar.current
        if let previousDay = calendar.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = previousDay
        }
    }

    private func goToNextDay() {
        let calendar = Calendar.current
        if let nextDay = calendar.date(byAdding: .day, value: 1, to: selectedDate),
           nextDay <= todayInMountainTime {
            selectedDate = nextDay
        }
    }

    private func loadPicture(for date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = mountainTimeZone
        formatter.locale = Locale(identifier: "en_US_POSIX")

        isLoading = true
        viewModel.preloadedAPODImage = nil
        Task {
            await viewModel.fetchPicture(for: formatter.string(from: date))
            isLoading = false
        }
    }

    private func saveImage(_ image: NSImage) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png]
        savePanel.nameFieldStringValue = "APOD-\(viewModel.picture?.date ?? "image").png"

        savePanel.begin { result in
            if result == .OK, let url = savePanel.url {
                if let tiffData = image.tiffRepresentation,
                   let bitmap = NSBitmapImageRep(data: tiffData),
                   let pngData = bitmap.representation(using: .png, properties: [:]) {
                    try? pngData.write(to: url)
                }
            }
        }
    }
}

// MARK: - Article View
struct MacArticleView: View {
    let articles: [GQLArticle]
    @State private var selectedArticle: GQLArticle?
    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly

    var sortedArticles: [GQLArticle] {
        articles.sorted { a, b in
            let yearA = a.year ?? 0
            let yearB = b.year ?? 0
            if yearA != yearB { return yearA > yearB }
            return (a.month ?? 0) > (b.month ?? 0)
        }
    }

    private let monthNames = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(sortedArticles, id: \.title, selection: $selectedArticle) { article in
                VStack(alignment: .leading, spacing: 4) {
                    Text(article.title ?? "Untitled")
                        .font(.headline)

                    if let authors = article.authors, !authors.isEmpty {
                        Text(authors.compactMap { $0.name }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let month = article.month, let year = article.year {
                        Text("\(monthNames[month]) \(String(year))")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.vertical, 4)
                .tag(article)
            }
            .navigationSplitViewColumnWidth(min: 250, ideal: 300)
        } detail: {
            if let article = selectedArticle, let urlString = article.url, let url = URL(string: urlString) {
                MacWebView(url: url)
                    .ignoresSafeArea()
            } else {
                ContentUnavailableView("Select an Article", systemImage: "doc.text", description: Text("Choose an article from the list"))
            }
        }
        .navigationTitle("Article of the Month")
        .navigationSubtitle("\(sortedArticles.count) articles")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                if let article = selectedArticle, let urlString = article.url, let url = URL(string: urlString) {
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .onAppear {
            if selectedArticle == nil, let first = sortedArticles.first {
                selectedArticle = first
            }
        }
    }
}

// MARK: - WebView
struct MacWebView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        if nsView.url != url {
            nsView.load(URLRequest(url: url))
        }
    }
}

// MARK: - Nature Scope
struct MacNatureScopeDetailView: View {
    @ObservedObject var viewModel: GQLViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Browse natural events and disasters from NASA Earth Observatory.")
                    .italic()
                    .fontDesign(.serif)
                    .foregroundStyle(.secondary)

                Text("Displaying events since \(getFormattedDate14DaysAgo())")
                    .italic()
                    .fontDesign(.serif)
                    .foregroundStyle(.secondary)

                if viewModel.eventsLoaded {
                    NavigationLink(destination: MacMapWithEvents(viewModel: viewModel)) {
                        Label("Enter Nature Scope", systemImage: "globe.americas")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.green)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                } else if viewModel.eventsFailed {
                    Label("Failed to Load", systemImage: "exclamationmark.triangle")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.red)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    ProgressView("Loading events...")
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Event Categories")
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)

                    Divider()

                    ForEach(categories) { category in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(category.title)
                                .font(.title2)
                                .fontWidth(.compressed)
                                .bold()

                            Text(category.description)
                                .italic()
                                .fontDesign(.serif)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 8)
                    }
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("Nature Scope")
    }
}

// MARK: - Helper
func convertDateString(dateString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    guard let date = dateFormatter.date(from: dateString) else {
        return ""
    }

    dateFormatter.dateStyle = .long
    return dateFormatter.string(from: date)
}
