//
//  Home.swift
//  Cosmofy for TV
//
//  Created by Arryan Bhatnagar on 7/16/24.
//

import Foundation
import SwiftUI

struct Home: View {
    @ObservedObject var viewModel: GQLViewModel

    var body: some View {
        HStack {
            // MARK: View 2 - Image
            VStack {
                HStack {
                    Text("Astronomy Picture of the Day")
                        .textCase(.uppercase)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                Divider()

                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                    Spacer()
                } else if let errorMessage = viewModel.pictureError {
                    Text(errorMessage)
                        .padding()
                        .foregroundColor(.red)
                    Spacer()
                } else if let picture = viewModel.picture {
                    if picture.media_type == "image" {
                        if let preloadedImage = viewModel.preloadedAPODImage {
                            Image(uiImage: preloadedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.vertical)
                                .padding(.trailing, 32)
                        } else if let mediaUrl = picture.media {
                            ImageView(mediaUrl)
                                .aspectRatio(contentMode: .fit)
                                .padding(.vertical)
                                .padding(.trailing, 32)
                        }
                    } else if picture.media_type == "video" {
                        Text("Video content cannot be displayed on Apple TV. Please view it on Cosmofy on your iPhone.")
                            .padding(.vertical)
                            .padding(.horizontal, 32)
                            .foregroundStyle(.red)
                    }
                    Spacer()
                } else {
                    ProgressView("Loading...")
                        .padding()
                    Spacer()
                }
            }

            // MARK: View 1 - Description
            VStack {
                HStack {
                    Text("description")
                        .textCase(.uppercase)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                Divider()

                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                    Spacer()
                } else if let errorMessage = viewModel.pictureError {
                    Text(errorMessage)
                        .padding()
                        .foregroundColor(.red)
                    Spacer()
                } else if let picture = viewModel.picture {
                    VStack {
                        HStack {
                            Text(picture.title ?? "Untitled")
                                .bold()
                                .fontWidth(.compressed)
                                .font(.title2)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        HStack {
                            Text(convertDateString(dateString: picture.date ?? ""))
                                .italic()
                                .fontDesign(.serif)
                            Spacer()
                        }

                        if let explanation = picture.explanation {
                            VStack {
                                Text(explanation.original ?? "")
                                    .font(.caption2)
                                    .padding(.vertical)
                                    .italic()
                                    .fontDesign(.serif)
                            }
                        }
                    }
                    Spacer()
                } else {
                    ProgressView("Loading...")
                        .padding()
                    Spacer()
                }
            }
        }
    }
}
