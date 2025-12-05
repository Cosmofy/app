//
//  TVMessageRowView.swift
//  Cosmofy for TV
//
//  Created by Arryan Bhatnagar on 7/12/24.
//

import Foundation
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
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
    
    func messageRow(text: String, image: String, color: Color, responseError: String? = nil, showDotLoading: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if image.hasPrefix("http"), let url = URL(string: image) {
                AsyncImage(url: url) {
                    image in image
                        .resizable()
                        .frame(width: 35, height: 35)
                } placeholder: {
                    ProgressView()
                }
            } else {
                HStack(spacing: 16) {
                    Image(image)
                        .resizable()
                        .frame(width: 35, height: 35)
                    
                    if image == "openai" {
                        Text("Swift")
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                            .font(.caption2)
                    } else {
                        Text(image)
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                            .font(.caption2)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {

                if image == "openai" {
                    if !complete {
//                        WordByWordTextView(text, interval: 0.075)
//                            .focusable()
//                            .multilineTextAlignment(.leading)
//                            .onAppear {
//                                complete = true
//                                print("garen text: \(text)")
//                            }
                        
                        ForEach(rowsFor(text: text), id: \.self) { text in
                            WordByWordTextView(text, interval: 0.075)
                                .focusable()
                                .multilineTextAlignment(.leading)
                                .onAppear {
                                    complete = true
                                }
                        }
                        
                    } else {
                        
                        ForEach(rowsFor(text: text), id: \.self) { text in
                            Text(text)
                                .focusable()
                                .multilineTextAlignment(.leading)
                        }
//                        Text(text)
//                            .focusable()
//                            .multilineTextAlignment(.leading)
//                            .onAppear {
//                                print("normal text: \(text)")
//                            }
//                            .font(.caption)
                    }
                    
                } else {
                    
                    ForEach(rowsFor(text: text), id: \.self) { text in
                        Markdown(text)
                            .focusable()
                            .multilineTextAlignment(.leading)
                    }
                    
//                    Markdown(text)
//                        .focusable()
//                        .multilineTextAlignment(.leading)
//                        .onAppear {
//                            print("markdown text: \(text)")
//                        }

//                        .font(.caption)
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
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(.ultraThinMaterial)
    
    }
    
}




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
