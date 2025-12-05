//
//  ImageView.swift
//  WatchCosmofy Watch App
//
//  Created by Arryan Bhatnagar on 6/17/24.
//

import Foundation
import SwiftUI
import Combine

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

struct LeftView: View {
    var body: some View {
        NavigationStack {
            WatchIOTDView()
                .navigationTitle("Picture of the Day")
                .navigationBarTitleDisplayMode(.inline)
                .padding(.horizontal)
        }
    }
}

// View for displaying APOD content on watchOS using GraphQL
struct WatchIOTDView: View {
    @State private var picture: GQLPicture?
    @State private var errorMessage: String?
    @State private var isLoading: Bool = true

    var body: some View {
        ScrollView {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .padding()
                    .foregroundColor(.red)
            } else if let picture = picture {
                VStack {
                    VStack {
                        HStack {
                            Text(picture.title ?? "Untitled")
                                .bold()
                                .fontWidth(.compressed)
                                .font(.title2)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.horizontal)
                        HStack {
                            Text(convertDateString(dateString: picture.date ?? ""))
                                .italic()
                                .font(.body)
                                .fontDesign(.serif)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)


                    if picture.media_type == "image" {
                        if let url = picture.media {
                            ImageView(url)
                                .aspectRatio(contentMode: .fit)
                                .padding()
                        }
                    } else if picture.media_type == "video" {
                        VStack {
                            Text("Video content cannot be displayed on Watch. Please view it on your iPhone.")
                                .padding()
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                        .padding()
                    }

                    VStack {
                        HStack {
                            Text("a brief explanation")
                                .font(.headline)
                                .textCase(.uppercase)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        Divider()
                            .tint(.secondary)
                    }
                    .padding([.top, .horizontal])

                    Text(picture.explanation?.original ?? "")
                        .italic()
                        .fontDesign(.serif)
                        .font(.caption)
                        .padding()
                }
            } else if isLoading {
                ProgressView("Loading...")
                    .padding()
            }
        }
        .task {
            await fetchPicture()
        }
    }

    private func fetchPicture() async {
        do {
            let response: PictureResponse = try await GraphQLClient.shared.execute(
                query: Queries.picture,
                variables: nil
            )
            self.picture = response.picture
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
        self.isLoading = false
    }
}

// View for displaying images
struct ImageView: View {
    @ObservedObject var imageLoader = ImageLoader()

    init(_ url: String) {
        self.imageLoader.load(url)
    }

    var body: some View {
        if let image = imageLoader.downloadedImage {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 4))

        } else {
            ProgressView("Loading...")
                .padding()
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
