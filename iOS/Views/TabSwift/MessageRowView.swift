#if swift(>=5.9)
//  ========================================
//  MessageRowView.swift
//  Cosmofy
//  4th Edition
//  Created by Arryan Bhatnagar on 10/24/23.
//  Abstract: UI for each row of the Chat VStack.
//  ========================================

import SwiftUI
// import MarkdownUI // Removed for iOS 9 compatibility

var complete: Bool = false

@available(iOS 17.0, *)
struct MessageRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    let message: MessageRow
    let retryCallback: (MessageRow) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            messageRow(text: message.sendText, image: message.sendImage, color: colorScheme == .light ? .white : Color(red: 20/255, green: 20/255, blue: 25/255, opacity: 1))
            
            if let text = message.responseText {
//                Divider()
                messageRow(text: text, image: message.responseImage, color: colorScheme == .light ? .white : Color(red: 24/255, green: 24/255, blue: 27/255, opacity: 1), responseError: message.responseError, showDotLoading: message.isInteractingWithChatGPT)
                    
//                Divider()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.vertical, 8)
        .padding(.horizontal)


    }
    
    func messageRow(text: String, image: String, color: Color, responseError: String? = nil, showDotLoading: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if image.hasPrefix("http"), let url = URL(string: image) {
                AsyncImage(url: url) {
                    image in image
                        .resizable()
                        .frame(width: 20, height: 20)
                } placeholder: {
                    ProgressView()
                }
            } else {
                HStack {
                    Image(image)
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    if image == "openai" {
                        Text("livia")
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                    } else {
                        Text(image)
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                #if os(iOS)
                if image == "openai" {
                    if !complete {
                        WordByWordTextView(text, interval: 0.075)
                            .multilineTextAlignment(.leading)
//                            .textSelection(.enabled)
                            .onAppear {
                                complete = true
                            }
                    } else {
                        Text(text)
                            .multilineTextAlignment(.leading)
//                            .textSelection(.enabled)
                    }
                    
//                        .font(Font.custom("SF Pro Rounded Medium", size: 18))
                } else {
                    // Markdown replaced with Text for iOS 9 compatibility
                    Text(text)
                        .multilineTextAlignment(.leading)
                        .textSelection(.enabled)
                }
                #else
                if image == "openai" {
                    if !complete {
                        WordByWordTextView(text, interval: 0.075)
                            .multilineTextAlignment(.leading)
                            .onAppear {
                                complete = true
                            }
                    } else {
                        Text(text)
                            .multilineTextAlignment(.leading)
                    }

                } else {
                    // Markdown replaced with Text for iOS 9 compatibility
                    Text(text)
                        .multilineTextAlignment(.leading)
                }
                #endif
                
                if let error = responseError {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                    
                    Button("Regenerate Response") {
                        retryCallback(message)
                    }
                    .foregroundColor(.blue)
                    .padding(.top)
                }
                
                if showDotLoading {
                    LoadingView(color: .BETRAYED)
                        .frame(height: 10)
//                        .frame(maxWidth: 25)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)


    }
}
#endif

