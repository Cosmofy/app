//
//  Home.swift
//  Cosmofy
//
//  Created by Arryan Bhatnagar on 3/9/24.
//

import SwiftUI
import MapKit
import WeatherKit
import CoreLocation
import VTabView

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

struct Home: View {

    @ObservedObject var viewModel: GQLViewModel
    @AppStorage("firstName") var currentFirstName: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                Text("Begin your space journey")
                    .foregroundStyle(.secondary)
                    .fontDesign(.rounded)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(.horizontal)

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

                Text("What would you like to do today?")
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
            .onAppear {
                UINavigationBar.appearance().largeTitleTextAttributes = [
                    .font: UIFont.systemFont(ofSize: 34, weight: .bold, width: .standard).rounded
                ]
            }
        }
    }
}

extension UIFont {
    var rounded: UIFont {
        guard let descriptor = fontDescriptor.withDesign(.rounded) else { return self }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}

struct ArticleView: View {
    let articles: [GQLArticle]
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var sortedArticles: [GQLArticle] {
        articles.sorted { a, b in
            let yearA = a.year ?? 0
            let yearB = b.year ?? 0
            if yearA != yearB { return yearA > yearB }
            return (a.month ?? 0) > (b.month ?? 0)
        }
    }

    var columns: [GridItem] {
        if horizontalSizeClass == .regular {
            return [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ]
        } else {
            return [GridItem(.flexible())]
        }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(sortedArticles, id: \.title) { article in
                    NavigationLink(destination: ArticleDetailView(article: article)) {
                        ArticleCard(article: article, isCompact: horizontalSizeClass == .regular)
                    }
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
                            .frame(width: geometry.size.width, height: isCompact ? 140 : 180)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: geometry.size.width, height: isCompact ? 140 : 180)
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: geometry.size.width, height: isCompact ? 140 : 180)
                }
            }
            .frame(height: isCompact ? 140 : 180)

            HStack {
                VStack {
                    Text(String(format: "%02d", article.month ?? 0))
                        .font(isCompact ? .title2 : .largeTitle)
                        .fontDesign(.serif)
                    Text(String(article.year ?? 2024))
                        .font(isCompact ? .caption : .body)
                        .fontDesign(.serif)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 4) {
                    HStack {
                        Text(article.title ?? "Untitled")
                            .multilineTextAlignment(.leading)
                            .font(.system(size: isCompact ? 14 : 16, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        Spacer()
                    }
                    HStack {
                        if let authors = article.authors, !authors.isEmpty {
                            Text(authors.compactMap { $0.name }.joined(separator: ", "))
                                .multilineTextAlignment(.leading)
                                .font(isCompact ? .caption2 : .caption)
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
        if let urlString = article.url, let url = URL(string: urlString) {
            WebView(urlString: urlString)
                .navigationTitle("Article of the Month")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: ShareLink(item: url, preview: SharePreview("Cosmofy's Article of the Month", image: Image("iconApp")))
                )
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
                            .font(Font.custom("SF Pro Rounded Medium", size: 18))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
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
                            .font(Font.custom("SF Pro Rounded Medium", size: 18))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    
                }
                Image(systemName: "chevron.right")
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
}


extension Text {
    public func foregroundLinearGradient(
        colors: [Color],
        startPoint: UnitPoint,
        endPoint: UnitPoint) -> some View
    {
        self.overlay {
            LinearGradient(
                colors: colors,
                startPoint: startPoint,
                endPoint: endPoint
            )
            .mask(self)
        }
    }
}

// MARK: - Picture of the Day

struct IOTDView: View {
    @ObservedObject var viewModel: GQLViewModel
    @State private var selectedDate: Date = IOTDView.currentMountainTimeDate()
    @State private var isLoading: Bool = false
    @State private var isSaved: Bool = false
    @State private var downloadButtonColor: Color = .indigo
    @State private var downloadButtonText: String = "Download"
    @State private var downloadButtonIcon: String = "arrow.down.to.line"

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
        ScrollView {
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading...")
                        .padding()
                    Spacer()
                }
                .frame(minHeight: 400)
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
                .frame(minHeight: 400)
            } else if let picture = viewModel.picture {
                VStack {
                    VStack(spacing: 8) {
                        VStack {
                            HStack {
                                Text("Astronomy Picture of the Day")
                                    .font(Font.system(size: 16))
                                    .textCase(.uppercase)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            Divider()
                        }

                        VStack {
                            HStack {
                                Text(picture.title ?? "Untitled")
                                    .font(Font.system(size: 42))
                                    .bold()
                                    .fontWidth(.compressed)
                                Spacer()
                            }
                            HStack {
                                Text(convertDateString(dateString: picture.date ?? ""))
                                    .italic()
                                    .font(.body)
                                    .fontDesign(.serif)
                                Spacer()
                            }
                        }
                    }
                    .padding()

                    if picture.media_type == "video" {
                        if let url = picture.media {
                            WebView(urlString: url)
                                .frame(height: 300)
                                .padding(.horizontal)
                        }
                    } else {
                        if let preloadedImage = viewModel.preloadedAPODImage {
                            VStack {
                                Image(uiImage: preloadedImage)
                                    .resizable()
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .aspectRatio(contentMode: .fill)

                                HStack {
                                    Button {
                                        UIImageWriteToSavedPhotosAlbum(preloadedImage, nil, nil, nil)
                                        withAnimation {
                                            isSaved = true
                                            downloadButtonColor = .green
                                            downloadButtonText = "Saved to Gallery"
                                            downloadButtonIcon = "checkmark.seal.fill"
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation {
                                                isSaved = false
                                                downloadButtonColor = .indigo
                                                downloadButtonText = "Download"
                                                downloadButtonIcon = "arrow.down.to.line"
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Spacer()
                                            Text(downloadButtonText)
                                                .padding(.vertical)
                                                .fontDesign(.rounded)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.white)
                                            Image(systemName: downloadButtonIcon)
                                                .foregroundStyle(.white)
                                                .fontWeight(.medium)
                                                .padding(.vertical)
                                            Spacer()
                                        }
                                        .frame(height: 50)
                                        .frame(maxWidth: .infinity)
                                        .background(downloadButtonColor)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

                                    ShareLink(item: Photo(image: Image(uiImage: preloadedImage), caption: "Astronomy Picture of the Day"), preview: SharePreview("Astronomy Picture of the Day", image: Image(uiImage: preloadedImage))) {
                                        Image(systemName: "square.and.arrow.up")
                                            .foregroundStyle(.secondary)
                                            .fontWeight(.medium)
                                    }
                                    .frame(width: 50, height: 50)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                .padding(.top, 8)
                            }
                            .padding(.horizontal)
                        } else if let mediaUrl = picture.media {
                            ImageView(mediaUrl)
                                .padding(.horizontal)
                        }
                    }

                    if let explanation = picture.explanation {
                        VStack {
                            HStack {
                                Text("a brief explanation")
                                    .font(Font.system(size: 16))
                                    .textCase(.uppercase)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            Divider()
                        }
                        .padding([.top, .horizontal])

                        Text(explanation.original ?? "")
                            .italic()
                            .font(.body)
                            .fontDesign(.serif)
                            .padding(.horizontal)

                        if let summarized = explanation.summarized, !summarized.isEmpty {
                            VStack {
                                HStack {
                                    Text("summary")
                                        .font(Font.system(size: 16))
                                        .textCase(.uppercase)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                                Divider()
                            }
                            .padding([.top, .horizontal])

                            Text(summarized)
                                .font(.body)
                                .fontDesign(.serif)
                                .padding(.horizontal)
                        }

                    }

                    if let copyright = picture.copyright, !copyright.isEmpty {
                        HStack {
                            Text("© \(copyright)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding()
                    }
                }
            } else {
                ProgressView("Loading...")
                    .padding()
            }
        }
        .navigationTitle("Picture of the Day")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: dateRange,
                    displayedComponents: .date
                )
                .labelsHidden()
                .disabled(isLoading)
                .onChange(of: selectedDate) { oldDate, newDate in
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
                .tint(.SOUR)
            }
        }
    }
}

// MARK: - Nature Scope

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
                                .bold()
                                .fontWidth(.compressed)
                            Spacer()
                        }
                    }

                    HStack {
                        Text("Displaying all events since \(getFormattedDate14DaysAgo())")
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
                            DisclosureGroup(category.title) {
                                HStack {
                                    Text(category.id)
                                        .font(.title)
                                        .fontDesign(.serif)
                                        .frame(width: 45)
                                    HStack {
                                        Text(category.description)
                                            .multilineTextAlignment(.leading)
                                            .foregroundStyle(.secondary)
                                            .fontDesign(.serif)
                                            .italic()
                                        Spacer()
                                    }
                                }
                            }
                        }
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
    @StateObject private var weatherViewModel = WeatherViewModel()

    var body: some View {
        ZStack {
            mapContent
            if selected {
                eventOverlay
            }
        }
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
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
        VStack {
            Spacer()
            VTabView(indexPosition: .trailing) {
                eventTitleView
                eventMapView
                eventDateView
            }
            .tabViewStyle(PageTabViewStyle())
            .padding()
            .frame(height: 200)
            .frame(maxWidth: 500)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .padding(.horizontal)
        .padding(.bottom, 24)
    }

    private var eventTitleView: some View {
        VStack {
            VStack(spacing: 4) {
                VStack(spacing: 2) {
                    HStack {
                        Text("event Title")
                            .font(.caption)
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    Divider()
                }
                .padding(.trailing, 50)

                HStack {
                    Text(selectedEvent?.title ?? "")
                        .multilineTextAlignment(.leading)
                        .font(Font.custom("SF Pro Rounded Medium", size: 18))
                    Spacer()
                }
                .padding(.trailing, 50)
            }

            if let event = selectedEvent, let categories = event.categories {
                ForEach(categories) { category in
                    categoryRow(category: category, event: event)
                }
            }
        }
    }

    private func categoryRow(category: GQLCategory, event: GQLEvent) -> some View {
        VStack {
            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(Color(markerTint(for: category.id)).gradient)
                    Image(systemName: markerImage(for: category.id))
                }
                .foregroundStyle(markerTint(for: category.id) == .white ? .black : .white)
                .frame(maxHeight: 35)

                VStack(spacing: 0) {
                    HStack {
                        Text(category.title ?? "")
                            .font(Font.custom("SF Pro Rounded Medium", size: 16))
                        Spacer()
                    }
                    HStack {
                        Text("Category")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
                Spacer()
            }

            Spacer()

            HStack {
                if category == event.categories?.first {
                    weatherView(for: event)
                }
                Spacer()
                Text(" Weather")
                    .fontWeight(.medium)
            }
        }
    }

    @ViewBuilder
    private func weatherView(for event: GQLEvent) -> some View {
        if let coords = event.geometry?.first?.coordinates, coords.count >= 2 {
            let latitude = coords[1]
            let longitude = coords[0]
            if let weather = weatherViewModel.weather {
                HStack(spacing: 2) {
                    Image(systemName: weather.currentWeather.symbolName)
                    Text(String(format: "%.1f", weather.currentWeather.temperature.value) + " \(weather.currentWeather.temperature.unit.symbol)")
                        .font(Font.custom("SF Pro Rounded Medium", size: 18))
                }
                .onAppear {
                    weatherViewModel.fetchWeather(latitude: latitude, longitude: longitude)
                }
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .onAppear {
                        weatherViewModel.fetchWeather(latitude: latitude, longitude: longitude)
                    }
            }
        }
    }

    private var eventMapView: some View {
        VStack {
            if let geometry = selectedEvent?.geometry, geometry.count == 1,
               let first = geometry.first?.coordinates, first.count >= 2 {
                let lat = first[1]
                let lon = first[0]
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))),
                    interactionModes: []) {
                }
                    .frame(height: 168)
                    .mapStyle(.hybrid(showsTraffic: false))
            } else if let geometry = selectedEvent?.geometry {
                Map(interactionModes: []) {
                    ForEach(geometry) { geo in
                        if let coords = geo.coordinates, coords.count >= 2 {
                            let lat = coords[1]
                            let lon = coords[0]
                            Annotation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
                                Circle()
                                    .foregroundStyle(.red)
                                    .frame(width: 6, height: 6)
                            } label: { }
                        }
                    }
                }
                .frame(height: 168)
                .mapStyle(.hybrid(showsTraffic: false))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var eventDateView: some View {
        VStack {
            let firstDate = selectedEvent?.geometry?.first?.date
            let lastDate = selectedEvent?.geometry?.last?.date

            if firstDate == lastDate {
                VStack(spacing: 4) {
                    VStack(spacing: 2) {
                        HStack {
                            Text("Date")
                                .font(.caption)
                                .textCase(.uppercase)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        Divider()
                    }
                    .padding(.trailing, 50)

                    HStack {
                        Text(formattedDate(from: firstDate ?? ""))
                            .font(Font.custom("SF Pro Rounded Medium", size: 18))
                        Spacer()
                    }
                }
                .padding(.top, 6)
            } else {
                VStack(spacing: 4) {
                    VStack(spacing: 2) {
                        HStack {
                            Text("Dates")
                                .font(.caption)
                                .textCase(.uppercase)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        Divider()
                    }
                    .padding(.trailing, 50)

                    HStack {
                        Text("\(formattedDate(from: firstDate ?? "")) to")
                            .font(Font.custom("SF Pro Rounded Medium", size: 18))
                        Spacer()
                    }
                    HStack {
                        Text(formattedDate(from: lastDate ?? ""))
                            .font(Font.custom("SF Pro Rounded Medium", size: 18))
                        Spacer()
                    }
                }
                .padding(.top, 6)
            }

            if let sources = selectedEvent?.sources {
                VStack(spacing: 2) {
                    HStack {
                        Text("sources")
                            .font(.caption)
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    Divider()
                }
                .padding(.trailing, 50)
                .padding(.top)

                ForEach(sources) { source in
                    HStack {
                        Text(getSourceTitle(by: source.id) ?? source.id)
                            .font(Font.custom("SF Pro Rounded Medium", size: 18))
                        Spacer()
                    }
                }
            }
        }
    }
}
