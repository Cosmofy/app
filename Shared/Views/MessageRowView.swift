//
//  MessageRowView.swift
//  Cosmofy
//
//  Shared message row view for Livia chat across all platforms
//

import SwiftUI
import MarkdownUI

fileprivate var complete: Bool = false

struct MessageRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    let message: MessageRow
    let retryCallback: (MessageRow) -> Void

    var body: some View {
        VStack(spacing: 0) {
            messageRow(
                text: message.sendText,
                image: message.sendImage,
                color: colorScheme == .light ? .white : Color(red: 20/255, green: 20/255, blue: 25/255, opacity: 1)
            )

            if let text = message.responseText {
                messageRow(
                    text: text,
                    image: message.responseImage,
                    color: colorScheme == .light ? .white : Color(red: 24/255, green: 24/255, blue: 27/255, opacity: 1),
                    responseError: message.responseError,
                    showDotLoading: message.isInteractingWithChatGPT
                )
            }
        }
        #if os(iOS)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.vertical, 8)
        .padding(.horizontal)
        #elseif os(tvOS)
        .padding(.vertical, 8)
        .padding(.horizontal)
        #elseif os(watchOS)
        // No extra padding for watchOS
        #else
        .padding(.vertical, 8)
        .padding(.horizontal)
        #endif
    }

    func messageRow(text: String, image: String, color: Color, responseError: String? = nil, showDotLoading: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: platformSpacing) {
            // Avatar and label
            if image.hasPrefix("http"), let url = URL(string: image) {
                AsyncImage(url: url) { img in
                    img.resizable().frame(width: avatarSize, height: avatarSize)
                } placeholder: {
                    ProgressView()
                }
            } else {
                HStack(spacing: platformLabelSpacing) {
                    Image(image)
                        .resizable()
                        .frame(width: avatarSize, height: avatarSize)

                    if image == "openai" {
                        Text("livia")
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                            .font(labelFont)
                    } else {
                        Text(image)
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                            .font(labelFont)
                    }
                }
            }

            // Message content
            VStack(alignment: .leading, spacing: 0) {
                #if os(tvOS)
                // tvOS needs focusable rows for navigation
                if image == "openai" {
                    if !complete {
                        ForEach(rowsFor(text: text), id: \.self) { row in
                            WordByWordTextView(row, interval: 0.075)
                                .focusable()
                                .multilineTextAlignment(.leading)
                                .onAppear { complete = true }
                        }
                    } else {
                        ForEach(rowsFor(text: text), id: \.self) { row in
                            Text(row)
                                .focusable()
                                .multilineTextAlignment(.leading)
                        }
                    }
                } else {
                    ForEach(rowsFor(text: text), id: \.self) { row in
                        Markdown(row)
                            .focusable()
                            .multilineTextAlignment(.leading)
                    }
                }
                #elseif os(watchOS)
                if image == "openai" {
                    if !complete {
                        WordByWordTextView(text, interval: 0.075)
                            .font(.caption2)
                            .multilineTextAlignment(.leading)
                            .onAppear { complete = true }
                    } else {
                        Text(text)
                            .multilineTextAlignment(.leading)
                            .font(.caption2)
                    }
                } else {
                    Markdown(text)
                        .font(.caption2)
                }
                #elseif os(iOS)
                // iOS
                if image == "openai" {
                    if !complete {
                        WordByWordTextView(text, interval: 0.075)
                            .multilineTextAlignment(.leading)
                            .onAppear { complete = true }
                    } else {
                        Text(text)
                            .multilineTextAlignment(.leading)
                    }
                } else {
                    Markdown(text)
                        .multilineTextAlignment(.leading)
                        .textSelection(.enabled)
                }
                #else
                // macOS - no WordByWordTextView
                if image == "openai" {
                    Text(text)
                        .multilineTextAlignment(.leading)
                        .textSelection(.enabled)
                } else {
                    Markdown(text)
                        .multilineTextAlignment(.leading)
                        .textSelection(.enabled)
                }
                #endif

                // Error handling
                if let error = responseError {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.leading)

                    Button("Regenerate Response") {
                        retryCallback(message)
                    }
                    .foregroundColor(.blue)
                    .padding(.top)
                }

                // Loading indicator
                if showDotLoading {
                    LoadingView(color: .BETRAYED)
                        .frame(height: 10)
                }
            }
        }
        .padding(platformPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        #if !os(tvOS) && !os(watchOS)
        .background(.ultraThinMaterial)
        #endif
    }

    // MARK: - Platform-specific values

    private var avatarSize: CGFloat {
        #if os(watchOS)
        return 20
        #elseif os(tvOS)
        return 35
        #else
        return 20
        #endif
    }

    private var platformSpacing: CGFloat {
        #if os(watchOS)
        return 8
        #elseif os(tvOS)
        return 12
        #else
        return 12
        #endif
    }

    private var platformLabelSpacing: CGFloat {
        #if os(tvOS)
        return 16
        #else
        return 8
        #endif
    }

    private var platformPadding: CGFloat {
        #if os(watchOS)
        return 8
        #else
        return 16
        #endif
    }

    private var labelFont: Font {
        #if os(tvOS)
        return .caption2
        #else
        return .footnote
        #endif
    }
}

// MARK: - tvOS Helper

#if os(tvOS)
private func rowsFor(text: String) -> [String] {
    var rows = [String]()
    let maxLinesPerRow = 8
    var currentRowText = ""
    var currentLineSum = 0

    for char in text {
        currentRowText += String(char)
        if char == "\n" {
            currentLineSum += 1
        }

        if currentLineSum >= maxLinesPerRow {
            rows.append(currentRowText)
            currentLineSum = 0
            currentRowText = ""
        }
    }

    rows.append(currentRowText)
    return rows
}
#endif
