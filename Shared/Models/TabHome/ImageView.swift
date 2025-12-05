import SwiftUI
import Combine
#if !os(tvOS)
import WebKit
#endif

var today = ""
var done = false

#if os(macOS)
import AppKit

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
#else
class ImageLoader: ObservableObject {
    @Published var downloadedImage: UIImage? = nil
    private var cancellable: AnyCancellable?

    func load(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
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
#endif

struct Photo: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }

    public var image: Image
    public var caption: String
}

// View for displaying images
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
                #if os(macOS)
                Image(nsImage: image)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .aspectRatio(contentMode: .fill)
                #else
                Image(uiImage: image)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .aspectRatio(contentMode: .fill)
                #endif
                #if os(iOS)
                HStack {
                    Button {
                        UIImageWriteToSavedPhotosAlbum(imageLoader.downloadedImage!, nil, nil, nil)
                        // Animate and change the button color on success
                        withAnimation {
                            isSaved = true
                            buttonColor = .green // Change button color on success
                            text = "Saved to Gallery"
                            imageIcon = "checkmark.seal.fill"
                        }
                        // Reset the state after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isSaved = false
                                buttonColor = .indigo // Reset button color
                                text = "Download"
                                imageIcon = "arrow.down.to.line"
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text(text)
                                .padding(.vertical)
                                .fontDesign(.rounded)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            Image(systemName: imageIcon)
                                .foregroundStyle(.white)
                                .fontWeight(.medium)
                                .padding(.vertical)
                            Spacer()
                        }
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(buttonColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

                    ShareLink(item: Photo(image: Image(uiImage: imageLoader.downloadedImage!), caption: "Astronomy Picture of the Day"), preview: SharePreview(Photo(image: Image(uiImage: imageLoader.downloadedImage!), caption: "Astronomy Picture of the Day").caption, image: Photo(image: Image(uiImage: imageLoader.downloadedImage!), caption: "").image)) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(.secondary)
                            .fontWeight(.medium)
                    }
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.top, 8)

                #endif

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

func subtractOneDay(from dateString: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    guard let date = dateFormatter.date(from: dateString) else {
        return nil
    }

    let calendar = Calendar.current
    if let newDate = calendar.date(byAdding: .day, value: -1, to: date) {
        return dateFormatter.string(from: newDate)
    }

    return nil
}

func addOneDay(from dateString: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    guard let date = dateFormatter.date(from: dateString) else {
        return nil
    }

    let calendar = Calendar.current
    if let newDate = calendar.date(byAdding: .day, value: +1, to: date) {
        return dateFormatter.string(from: newDate)
    }

    return nil
}


#if os(macOS)
import AppKit

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

#elseif !os(tvOS)

struct WebView: UIViewRepresentable {

    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: urlString) else {
            return WKWebView()
        }
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}

#endif

struct WordByWordTextView: View {
    let fullText: String
    let animationInterval: TimeInterval
    @State private var displayedText: String = ""
    private let words: [String]

    init(_ text: String, interval: TimeInterval = 0.35) {
        self.fullText = text
        self.animationInterval = interval
        self.words = text.split { $0.isWhitespace }.map(String.init)
    }

    var body: some View {
        HStack {
            Text(displayedText)
                .onAppear {
                    if displayedText == "" {
                        DispatchQueue.main.async {
                            self.animateText()
                        }
                    }
                }
            Spacer()
        }
    }

    private func animateText() {
        var currentWordIndex = 0
        Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: true) { timer in
            if currentWordIndex < words.count {
                let word = words[currentWordIndex]
                displayedText += (currentWordIndex == 0 ? "" : " ") + word
                currentWordIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
}

func convertDateString(dateString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    guard let date = dateFormatter.date(from: dateString) else {
        return "Invalid date"
    }

    dateFormatter.dateStyle = .full
    return dateFormatter.string(from: date)
}
