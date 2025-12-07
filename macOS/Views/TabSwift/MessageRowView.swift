//  ========================================
//  MessageRowView.swift
//  Cosmofy
//  4th Edition
//  Created by Arryan Bhatnagar on 10/24/23.
//  Abstract: UI for each row of the Chat VStack.
//  ========================================

import SwiftUI
import MarkdownUI

var complete: Bool = false

struct MessageRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    let message: MessageRow
    let retryCallback: (MessageRow) -> Void

    var body: some View {
        VStack(spacing: 12) {
            // User message
            userMessageRow(text: message.sendText)

            // AI Response
            if let text = message.responseText {
                aiMessageRow(text: text, responseError: message.responseError, showDotLoading: message.isInteractingWithChatGPT)
            }
        }
        .padding(.vertical, 8)
    }

    // User message - aligned right
    func userMessageRow(text: String) -> some View {
        HStack {
            Spacer()

            HStack(alignment: .top, spacing: 12) {
                Text(text)
                    .font(.body)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.trailing)
                    .padding(16)
                    .background(Color.SOUR.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                Image("user")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            }
        }
    }

    // AI message - aligned left
    func aiMessageRow(text: String, responseError: String? = nil, showDotLoading: Bool = false) -> some View {
        HStack {
            HStack(alignment: .top, spacing: 12) {
                Image("swift")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Swift")
                        .font(.body)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    VStack(alignment: .leading, spacing: 0) {
                        if !complete {
                            WordByWordTextView(text, interval: 0.075)
                                .font(.title3)
                                .fontDesign(.rounded)
                                .multilineTextAlignment(.leading)
                                .onAppear {
                                    complete = true
                                }
                        } else {
                            Text(text)
                                .font(.title3)
                                .fontDesign(.rounded)
                                .multilineTextAlignment(.leading)
                        }

                        if let error = responseError {
                            Text("Error: \(error)")
                                .foregroundColor(.red)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 8)

                            Button("Regenerate Response") {
                                retryCallback(message)
                            }
                            .foregroundColor(.blue)
                            .padding(.top)
                        }

                        if showDotLoading {
                            LoadingView(color: .BETRAYED)
                                .frame(height: 10)
                                .padding(.top, 8)
                        }
                    }
                    .padding(16)
                    .background(colorScheme == .light ? Color.gray.opacity(0.1) : Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }

            Spacer()
        }
    }
}
