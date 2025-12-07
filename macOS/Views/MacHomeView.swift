//
//  MacHomeView.swift
//  Cosmofy macOS
//
//  Home view for macOS
//

import SwiftUI
import MapKit
import WeatherKit
import CoreLocation
import Combine
import VTabView
import UniformTypeIdentifiers

struct Home: View {

    @ObservedObject var viewModel: GQLViewModel
    @AppStorage("firstName") var currentFirstName: String?

    var body: some View {
        NavigationStack {
            ScrollView {


                Text("Hello \(currentFirstName ?? "individual").")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .font(.largeTitle)
                    .fontDesign(.rounded)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue,
                                Color.purple,
                                Color.pink,
                                Color.orange,
                                Color.yellow
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.top, 32)
                    .padding(.horizontal)
                
                Text("Begin your space journey")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .fontDesign(.rounded)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(.horizontal)

                Text("What would you like to do today?")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .fontDesign(.rounded)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.bottom, 32)

                NavView(
                    view: IOTDView(viewModel: viewModel),
                    imageName: "home-icon-2",
                    title: "Picture of the Day",
                    subtitle: "View a new astronomy image every day"
                )

                NavView(
                    view: ArticleView(articles: viewModel.articles),
                    imageName: "home-icon-1",
                    title: "Article of the Month",
                    subtitle: "Read a new space article every month"
                )

                NavView(
                    view: NatureScope(viewModel: viewModel),
                    imageName: "home-icon-4",
                    title: "Nature Scope",
                    subtitle: "View natural events and disasters around the globe"
                )
            }
            .navigationTitle("Cosmofy")
        }
    }
}

struct ArticleView: View {
    let articles: [GQLArticle]

    var sortedArticles: [GQLArticle] {
        articles.sorted { a, b in
            let yearA = a.year ?? 0
            let yearB = b.year ?? 0
            if yearA != yearB { return yearA > yearB }
            return (a.month ?? 0) > (b.month ?? 0)
        }
    }

    var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(sortedArticles, id: \.title) { article in
                    NavigationLink(destination: ArticleDetailView(article: article)) {
                        ArticleCard(article: article, isCompact: true)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle("Articles")
    }
}

struct ArticleCard: View {
    let article: GQLArticle
    var isCompact: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                if let bannerUrl = article.banner?.image, let url = URL(string: bannerUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: isCompact ? 160 : 200)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: geometry.size.width, height: isCompact ? 160 : 200)
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: geometry.size.width, height: isCompact ? 160 : 200)
                }
            }
            .frame(height: isCompact ? 160 : 200)

            HStack {
                VStack {
                    Text(String(format: "%02d", article.month ?? 0))
                        .font(isCompact ? .title : .largeTitle)
                        .fontDesign(.serif)
                    Text(String(article.year ?? 2024))
                        .font(isCompact ? .title3 : .headline)
                        .fontDesign(.serif)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 4) {
                    HStack {
                        Text(article.title ?? "Untitled")
                            .multilineTextAlignment(.leading)
                            .font(.system(size: isCompact ? 16 : 18, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        Spacer()
                    }
                    HStack {
                        if let authors = article.authors, !authors.isEmpty {
                            Text(authors.compactMap { $0.name }.joined(separator: ", "))
                                .multilineTextAlignment(.leading)
                                .font(isCompact ? .title3 : .title3)
                                .italic()
                                .fontDesign(.serif)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                
                        }
                        Spacer()
                    }
                }
                .padding(.leading, isCompact ? 8 : 16)
                Spacer()
            }
            .padding(isCompact ? 12 : 16)
            .background(Color.gray.opacity(0.1))
        }
        .clipShape(RoundedRectangle(cornerRadius: isCompact ? 12 : 18))
    }
}

struct ArticleDetailView: View {
    let article: GQLArticle

    var body: some View {
        if let urlString = article.url, let _ = URL(string: urlString) {
            WebView(urlString: urlString)
                .navigationTitle("Article of the Month")
        } else {
            Text("Article URL not available")
                .foregroundStyle(.secondary)
        }
    }
}

struct NavView<Destination: View>: View {

    var view: Destination
    var imageName: String
    var title: String
    var subtitle: String

    var body: some View {
        NavigationLink(destination: view) {
            HStack(spacing: 16) {

                Image(imageName)
                    .resizable()
                    .frame(width: 32, height: 32)

                VStack {
                    HStack {
                        Text(title)
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.leading)
                            .tracking(-0.25)
                        if title == "Astronauts" {
                            Text("NEW")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                                .padding(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4.0)
                                        .stroke(lineWidth: 1.0)
                                        .foregroundStyle(.orange)
                                )
                        } else {
                            Text("")
                                .font(.caption2)
                                .foregroundStyle(.clear)
                                .padding(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4.0)
                                        .stroke(lineWidth: 1.0)
                                        .foregroundStyle(.clear)
                                )
                        }
                        Spacer()
                    }

                    HStack {
                        Text(subtitle)
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .font(.title3)

                        Spacer()
                    }

                }
                Image(systemName: "chevron.right")
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

}

// MARK: - Image Document for File Export

struct ImageDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.png] }

    var image: NSImage

    init(image: NSImage) {
        self.image = image
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents,
           let image = NSImage(data: data) {
            self.image = image
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            throw CocoaError(.fileWriteUnknown)
        }
        return FileWrapper(regularFileWithContents: pngData)
    }
}

// MARK: - Picture of the Day

struct IOTDView: View {
    @ObservedObject var viewModel: GQLViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedDate: Date = IOTDView.currentMountainTimeDate()
    @State private var isLoading: Bool = false
    @State private var isSaved: Bool = false
    @State private var downloadButtonColor: Color = .indigo
    @State private var downloadButtonText: String = "Download"
    @State private var downloadButtonIcon: String = "arrow.down.to.line"
    @State private var showingSavePanel: Bool = false
    @State private var showingDatePicker: Bool = false

    static func currentMountainTimeDate() -> Date {
        let mountainTimeZone = TimeZone(identifier: "America/Denver")!
        var calendar = Calendar.current
        calendar.timeZone = mountainTimeZone
        return calendar.startOfDay(for: Date())
    }

    var dateRange: ClosedRange<Date> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let minDate = dateFormatter.date(from: "1995-06-16")!
        return minDate...IOTDView.currentMountainTimeDate()
    }

    var body: some View {
        ZStack {
            if isLoading || viewModel.picture == nil {
                // Central loading indicator
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.BETRAYED)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.pictureError {
                VStack(spacing: 16) {
                    Text(errorMessage)
                        .padding()
                        .foregroundStyle(.red)
                    Button("Retry") {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        let dateString = dateFormatter.string(from: selectedDate)

                        isLoading = true
                        Task {
                            await viewModel.fetchPicture(for: dateString)
                            isLoading = false
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let picture = viewModel.picture, viewModel.preloadedAPODImage != nil || picture.media_type == "video" {
                HStack(alignment: .top, spacing: 24) {
                    // MARK: Left side - Image
                    VStack {
                        if picture.media_type == "video" {
                            if let url = picture.media {
                                WebView(urlString: url)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .padding(.vertical)
                            }
                        } else if let preloadedImage = viewModel.preloadedAPODImage {
                            VStack {
                                Image(nsImage: preloadedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .padding(.vertical)

                                HStack(spacing: 12) {
                                    Button {
                                        if let mediaUrl = picture.media, let url = URL(string: mediaUrl) {
                                            NSWorkspace.shared.open(url)
                                        }
                                    } label: {
                                        HStack {
                                            Spacer()
                                            Text("Open in Browser")
                                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                .foregroundStyle(.white)
                                            Image(systemName: "safari")
                                                .font(.system(size: 18, weight: .medium))
                                                .foregroundStyle(.white)
                                            Spacer()
                                        }
                                        .padding(.vertical, 16)
                                        .background(Color.indigo)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .buttonStyle(.plain)

                                    ShareLink(item: Image(nsImage: preloadedImage), preview: SharePreview("APOD", image: Image(nsImage: preloadedImage))) {
                                        HStack {
                                            Spacer()
                                            Image(systemName: "square.and.arrow.up")
                                                .font(.system(size: 18, weight: .medium))
                                                .foregroundStyle(colorScheme == .light ? .white : .black)
                                            Spacer()
                                        }
                                        .padding(.vertical, 16)
                                        .background(colorScheme == .light ? Color.gray.opacity(0.6) : Color.gray.opacity(0.3))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .buttonStyle(.plain)
                                    .frame(width: 60)
                                }
                            }
                        }
                        Spacer()
                    }

                    // MARK: Right side - Description
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(picture.title ?? "Untitled")
                                .font(.system(size: 42))
                                .bold()
                                .fontWidth(.compressed)
                                .multilineTextAlignment(.leading)

                            HStack {
                                Text(convertDateString(dateString: picture.date ?? ""))
                                    .font(.system(size: 18))
                                    .italic()
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.secondary)

                                Button {
                                    showingDatePicker.toggle()
                                } label: {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.indigo)
                                }
                                .buttonStyle(.plain)
                                .popover(isPresented: $showingDatePicker) {
                                    DatePicker(
                                        "",
                                        selection: $selectedDate,
                                        in: dateRange,
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(.graphical)
                                    .labelsHidden()
                                    .disabled(isLoading)
                                    .onChange(of: selectedDate) { oldDate, newDate in
                                        showingDatePicker = false
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd"
                                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                        let dateString = dateFormatter.string(from: newDate)

                                        isLoading = true
                                        viewModel.picture = nil
                                        viewModel.pictureError = nil
                                        viewModel.preloadedAPODImage = nil
                                        Task {
                                            await viewModel.fetchPicture(for: dateString)
                                            isLoading = false
                                        }
                                    }
                                    .padding()
                                }

                                Spacer()
                            }

                            if let explanation = picture.explanation {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Description")
                                        .font(.system(size: 18))
                                        .textCase(.uppercase)
                                        .foregroundColor(.secondary)

                                    Text(explanation.original ?? "")
                                        .font(.title3)
                                        .italic()
                                        .fontDesign(.serif)
                                }
                                .padding(.top, 20)

                                if let summarized = explanation.summarized, !summarized.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Summary")
                                            .font(.system(size: 18))
                                            .textCase(.uppercase)
                                            .foregroundColor(.secondary)

                                        Text(summarized)
                                            .font(.title3)
                                            .fontDesign(.serif)
                                    }
                                    .padding(.top, 20)
                                }
                            }

                            if let copyright = picture.copyright, !copyright.isEmpty {
                                Text("© \(copyright)")
                                    .font(.system(size: 16))
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 12)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Picture of the Day")
    }
}

// MARK: - Nature Scope

class WeatherViewModel: ObservableObject {
    @Published var weather: Weather?
    private let weatherService = WeatherService.shared

    func fetchWeather(latitude: Double, longitude: Double) {
        Task {
            do {
                let location = CLLocation(latitude: latitude, longitude: longitude)
                let weather = try await weatherService.weather(for: location)
                await MainActor.run {
                    self.weather = weather
                }
            } catch {
                print("Error fetching weather: \(error)")
            }
        }
    }
}

struct NatureScope: View {
    @ObservedObject var viewModel: GQLViewModel

    var body: some View {
        ScrollView {
                VStack {
                    HStack {
                        Text("from the NASA Earth Observatory")
                            .font(Font.system(size: 16))
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    Divider()

                    VStack {
                        HStack {
                            Text("Browse the Entire EARTH For Natural Events and disasters as They Occur")
                                .textCase(.uppercase)
                                .font(Font.system(size: 42))
                                .fontWeight(.semibold)
                                .fontWidth(.compressed)
                            Spacer()
                        }
                    }

                    HStack {
                        Text("Displaying all events since \(getFormattedDate14DaysAgo())")
                            .font(.title3)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.secondary)
                            .fontDesign(.serif)
                            .italic()
                        Spacer()
                    }
                    .padding(.top, 2)
                    .padding(.bottom, 8)

                    NavigationLink(destination: NatureScopeMap(viewModel: viewModel)) {
                        HStack {
                            Text("Enter Nature Scope")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.medium)
                                .foregroundColor(Color.white)
                        }
                        .frame(height: 30)
                        .padding()
                        .background(Color.green.cornerRadius(8))
                    }
                    .buttonStyle(.plain)

                    HStack {
                        Text("Current categories")
                            .font(Font.system(size: 16))
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.top)
                    Divider()

                    ForEach(categories) { category in
                        VStack {
                            HStack {
                                Text(category.id)
                                    .fontDesign(.serif)
                                    .font(.title2)
                                Text(category.title)
                                    .font(.title2)
                                Spacer()
                            }
                           
                            HStack {
                                Text(category.description)
                                    .font(.title3)
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(.secondary)
//                                        .fontDesign(.serif)
                                Spacer()
                            }
                        }
                        .padding(.vertical)
                    }
                    Spacer()
                }
                .padding()
            }
        .navigationTitle("Nature Scope")
    }
}

struct NatureScopeMap: View {
    @ObservedObject var viewModel: GQLViewModel
    @State var selectedEvent: GQLEvent?
    @State var selected: Bool = false
    @State private var showMiniMap: Bool = false

    var body: some View {
        ZStack {
            mapContent
            if selected {
                eventOverlay
            }
        }
        .navigationTitle("Map")
        .onChange(of: selectedEvent) { _, new in
            showMiniMap = false
            if new != nil {
                // Delay mini map loading
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showMiniMap = true
                }
            }
        }
    }

    private var mapContent: some View {
        Map(selection: $selectedEvent) {
            ForEach(viewModel.events) { event in
                let categoryId = event.categories?.first?.id ?? "default"
                let lat = event.geometry?.last?.coordinates?.last ?? -999
                let lon = event.geometry?.last?.coordinates?.first ?? -999
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)

                Marker("", systemImage: markerImage(for: categoryId), coordinate: coord)
                    .tint(markerTint(for: categoryId))
                    .tag(event)
            }
        }
        .onChange(of: selectedEvent) { old, new in
            withAnimation {
                selected = new != nil
            }
        }
        .mapControls {
            MapCompass()
            MapScaleView()
            MapPitchToggle()
        }
        .mapStyle(.standard(elevation: .realistic))
    }

    private var eventOverlay: some View {
        HStack {
            Spacer()
            ZStack {
                VStack {
                    // Event name
                    VStack {
                        VStack(spacing: 2) {
                            HStack {
                                Text("Event name")
                                    .font(.caption2)
                                    .textCase(.uppercase)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            Divider()
                        }

                        HStack {
                            Text(selectedEvent?.title ?? "")
                                .multilineTextAlignment(.leading)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                            Spacer()
                        }

                        if let categories = selectedEvent?.categories {
                            ForEach(categories) { category in
                                HStack(spacing: 8) {
                                    ZStack {
                                        Circle().fill(Color(markerTint(for: category.id)).gradient)
                                        Image(systemName: markerImage(for: category.id))
                                    }
                                    .foregroundStyle(markerTint(for: category.id) == .white ? .black : .white)
                                    .frame(maxHeight: 40)

                                    VStack(spacing: 0) {
                                        HStack {
                                            Text(category.title ?? "")
                                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                            Spacer()
                                        }
                                        HStack {
                                            Text("Event Category")
                                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                                .foregroundStyle(.secondary)
                                            Spacer()
                                        }
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }

                    // Mini map (lazy loaded)
                    VStack {
                        if showMiniMap {
                            if let geometry = selectedEvent?.geometry, geometry.count == 1,
                               let first = geometry.first?.coordinates, first.count >= 2 {
                                let lat = first[1]
                                let lon = first[0]
                                Map(initialPosition: .region(MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))),
                                    interactionModes: []) {
                                }
                                .frame(height: 180)
                                .mapStyle(.hybrid(showsTraffic: false))

                            } else if let geometry = selectedEvent?.geometry {
                                Map(interactionModes: []) {
                                    ForEach(geometry) { geo in
                                        if let coords = geo.coordinates, coords.count >= 2 {
                                            Annotation(coordinate: CLLocationCoordinate2D(
                                                latitude: coords[1],
                                                longitude: coords[0]), content: {
                                                    Circle()
                                                        .foregroundStyle(.red)
                                                        .frame(width: 6, height: 6)
                                                }) {
                                                }
                                        }
                                    }
                                }
                                .frame(height: 180)
                                .mapStyle(.hybrid(showsTraffic: false))
                            }
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.secondary.opacity(0.2))
                                .frame(height: 180)
                                .overlay {
                                    ProgressView()
                                }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Dates
                    VStack {
                        let firstDate = selectedEvent?.geometry?.first?.date
                        let lastDate = selectedEvent?.geometry?.last?.date

                        if firstDate == lastDate {
                            VStack(spacing: 4) {
                                VStack(spacing: 2) {
                                    HStack {
                                        Text("Recorded on")
                                            .font(.caption2)
                                            .textCase(.uppercase)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                    }
                                    Divider()
                                }

                                HStack {
                                    Text(formattedDate(from: firstDate ?? ""))
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                    Spacer()
                                }
                            }
                            .padding(.top, 6)
                        } else {
                            VStack(spacing: 4) {
                                VStack(spacing: 2) {
                                    HStack {
                                        Text("First Record")
                                            .font(.caption2)
                                            .textCase(.uppercase)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                    }
                                    Divider()
                                }

                                HStack {
                                    Text(formattedDate(from: firstDate ?? ""))
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                    Spacer()
                                }
                            }
                            .padding(.top, 6)

                            VStack(spacing: 4) {
                                VStack(spacing: 2) {
                                    HStack {
                                        Text("Latest Record")
                                            .font(.caption2)
                                            .textCase(.uppercase)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                    }
                                    Divider()
                                }

                                HStack {
                                    Text(formattedDate(from: lastDate ?? ""))
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                    Spacer()
                                }
                            }
                            .padding(.top, 6)
                        }

                        // Sources
                        if let sources = selectedEvent?.sources {
                            VStack(spacing: 2) {
                                HStack {
                                    Text("Source")
                                        .font(.caption2)
                                        .textCase(.uppercase)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                                Divider()
                            }
                            .padding(.top, 6)

                            ForEach(sources) { source in
                                VStack(spacing: 4) {
                                    HStack {
                                        Text(getSourceTitle(by: source.id) ?? source.id)
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: 320)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .padding()
        }
    }
}

// MARK: - Helper Functions

func convertDateString(dateString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    guard let date = dateFormatter.date(from: dateString) else {
        return "Invalid date"
    }

    dateFormatter.dateStyle = .full
    return dateFormatter.string(from: date)
}

// MARK: - WebView for macOS

import WebKit

struct WebView: NSViewRepresentable {
    let urlString: String

    func makeNSView(context: Context) -> WKWebView {
        guard let url = URL(string: urlString) else {
            return WKWebView()
        }
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
    }
}

// MARK: - ImageView for macOS

class ImageLoader: ObservableObject {
    @Published var downloadedImage: NSImage? = nil
    private var cancellable: AnyCancellable?

    func load(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { NSImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.downloadedImage = image
            }
    }

    deinit {
        cancellable?.cancel()
    }
}

struct ImageView: View {
    @ObservedObject var imageLoader = ImageLoader()
    @State private var isSaved = false
    @State private var buttonColor: Color = .indigo
    @State private var text = "Download"
    @State private var imageIcon = "arrow.down.to.line"

    init(_ url: String) {
        self.imageLoader.load(url)
    }

    var body: some View {
        if let image = imageLoader.downloadedImage {
            VStack {
                Image(nsImage: image)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .aspectRatio(contentMode: .fill)
            }
        } else {
            VStack {
                ProgressView("Loading...")
                    .padding()
            }
            .frame(height: 400)
        }
    }
}
