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
        VStack(spacing: 0) {
            messageRow(text: message.sendText, image: message.sendImage, color: colorScheme == .light ? .white : Color(red: 20/255, green: 20/255, blue: 25/255, opacity: 1))
            
            if let text = message.responseText {
                messageRow(text: text, image: message.responseImage, color: colorScheme == .light ? .white : Color(red: 24/255, green: 24/255, blue: 27/255, opacity: 1), responseError: message.responseError, showDotLoading: message.isInteractingWithChatGPT)
            }
        }
    }
    
    func messageRow(text: String, image: String, color: Color, responseError: String? = nil, showDotLoading: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
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
                        Text("swift")
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

                if image == "openai" {
                    if !complete {
                        WordByWordTextView(text, interval: 0.075)
                            .font(.caption2)
                            .multilineTextAlignment(.leading)
                            .onAppear {
                                complete = true
                            }
                    } else {
                        Text(text)
                            .multilineTextAlignment(.leading)
                            .font(.caption2)
                    }
                    
                } else {
                    Markdown(text)
                        .font(.caption2)
                }
                
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
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
