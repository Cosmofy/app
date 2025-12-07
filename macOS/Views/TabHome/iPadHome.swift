//
//  iPadHome.swift
//  Cosmofy
//
//  Created by Arryan Bhatnagar on 6/27/24.
//

import SwiftUI
import UIKit

struct iPadHome: View {
    @ObservedObject var viewModel: GQLViewModel

    // Get sorted articles
    var sortedArticles: [GQLArticle] {
        viewModel.articles.sorted { a, b in
            let yearA = a.year ?? 0
            let yearB = b.year ?? 0
            if yearA != yearB {
                return yearA > yearB
            }
            return (a.month ?? 0) > (b.month ?? 0)
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    HStack {
                        // View 1 - APOD
                        VStack {
                            VStack {
                                HStack {
                                    Text("Astronomy Picture of the Day")
                                        .textCase(.uppercase)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                Divider()
                                    .padding(.horizontal)
                            }
                            .padding([.horizontal, .top])

                            if viewModel.isLoading {
                                ProgressView("Loading...")
                                    .padding()
                            } else if let errorMessage = viewModel.pictureError {
                                Text(errorMessage)
                                    .padding()
                                    .foregroundColor(.red)
                            } else if let picture = viewModel.picture {
                                VStack {
                                    VStack {
                                        HStack {
                                            Text(picture.title ?? "Untitled")
                                                .bold()
                                                .fontWidth(.compressed)
                                                .font(.title)
                                                .multilineTextAlignment(.leading)
                                            Spacer()
                                        }
                                        .padding(.horizontal)

                                        HStack {
                                            Text(convertDateString(dateString: picture.date ?? ""))
                                                .italic()
                                                .fontDesign(.serif)
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                    }
                                    .padding(.horizontal)

                                    if picture.media_type == "image" {
                                        if let preloadedImage = viewModel.preloadedAPODImage {
                                            Image(uiImage: preloadedImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .padding(.vertical)
                                                .padding(.horizontal, 32)
                                        } else if let mediaUrl = picture.media {
                                            ImageView(mediaUrl)
                                                .aspectRatio(contentMode: .fit)
                                                .padding(.vertical)
                                                .padding(.horizontal, 32)
                                        }
                                    } else if picture.media_type == "video" {
                                        if let mediaUrl = picture.media {
                                            WebView(urlString: mediaUrl)
                                                .frame(height: 300)
                                                .padding(.vertical)
                                        }
                                    }

                                    if let explanation = picture.explanation {
                                        Text(explanation.original ?? "")
                                            .padding(.horizontal, 32)
                                            .italic()
                                            .fontDesign(.serif)
                                    }

                                    Spacer()
                                }
                            } else {
                                ProgressView("Loading...")
                                    .padding()
                            }
                        }
                        .frame(maxWidth: .infinity)

                        // View 2 - Articles
                        VStack {
                            VStack {
                                HStack {
                                    Text("articles")
                                        .textCase(.uppercase)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                                Divider()
                            }
                            .padding(.top)
                            .padding(.horizontal, 32)

                            if viewModel.articles.isEmpty {
                                ProgressView("Loading articles...")
                                    .padding(.top, 50)
                            } else {
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ], spacing: 16) {
                                    ForEach(sortedArticles, id: \.title) { article in
                                        NavigationLink(destination: ArticleDetailView(article: article)) {
                                            iPadArticleCard(article: article)
                                        }
                                    }
                                }
                                .padding(.horizontal, 32)
                                .padding(.top)
                            }

                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Cosmofy")
            .onAppear {
                UINavigationBar.appearance().largeTitleTextAttributes = [
                    .font: UIFont(name: "SF Pro Rounded Bold", size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .semibold),
                ]
            }
        }
    }
}

struct iPadArticleCard: View {
    let article: GQLArticle

    var body: some View {
        VStack(spacing: 0) {
            // Banner image with fixed aspect ratio
            GeometryReader { geometry in
                if let bannerUrl = article.banner?.image, let url = URL(string: bannerUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: 140)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: geometry.size.width, height: 140)
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: geometry.size.width, height: 140)
                }
            }
            .frame(height: 140)

            HStack {
                VStack {
                    Text(String(format: "%02d", article.month ?? 0))
                        .font(.title2)
                        .fontDesign(.serif)

                    Text(String(article.year ?? 2024))
                        .font(.caption)
                        .fontDesign(.serif)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 4) {
                    HStack {
                        Text(article.title ?? "Untitled")
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        Spacer()
                    }

                    HStack {
                        if let authors = article.authors, !authors.isEmpty {
                            Text(authors.compactMap { $0.name }.joined(separator: ", "))
                                .multilineTextAlignment(.leading)
                                .font(.caption2)
                                .italic()
                                .fontDesign(.serif)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                }
                .padding(.leading, 8)

                Spacer()
            }
            .padding(12)
            .background(Color.gray.opacity(0.1))
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        return UIVisualEffectView()
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}
