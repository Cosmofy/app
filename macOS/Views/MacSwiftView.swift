//
//  MacSwiftView.swift
//  Cosmofy macOS
//
//  Created by Arryan Bhatnagar on 12/4/24.
//

import SwiftUI

struct MacSwiftView: View {
    @StateObject private var vm = InteractingViewModel(api: API())
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(vm.messages) { message in
                            VStack(alignment: .leading, spacing: 12) {
                                // User message
                                messageRow(
                                    text: message.sendText,
                                    image: "user",
                                    label: "User"
                                )

                                // Response
                                if let text = message.responseText {
                                    messageRow(
                                        text: text,
                                        image: "openai",
                                        label: "Swift",
                                        responseError: message.responseError,
                                        showLoading: message.isInteractingWithChatGPT,
                                        onRetry: {
                                            Task { await vm.retry(message: message) }
                                        }
                                    )
                                } else if message.isInteractingWithChatGPT {
                                    HStack(spacing: 12) {
                                        Image("openai")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Thinking...")
                                            .font(.system(size: 14))
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: vm.messages.last?.responseText) { _, _ in
                    if let id = vm.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Input
            HStack(spacing: 16) {
                Image("user")
                    .resizable()
                    .frame(width: 32, height: 32)

                TextField("Ask about space, planets, astronomy...", text: $vm.inputMessage, axis: .vertical)
                    .font(.system(size: 16))
                    .textFieldStyle(.plain)
                    .lineLimit(1...5)
                    .focused($isTextFieldFocused)
                    .disabled(vm.isInteractingWithChatGPT)
                    .onSubmit {
                        sendMessage()
                    }

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: vm.isInteractingWithChatGPT ? "stop.circle.fill" : "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : .SOUR)
                }
                .buttonStyle(.plain)
                .disabled(vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !vm.isInteractingWithChatGPT)
            }
            .padding(20)
        }
        .navigationTitle("Swift")
        .toolbar {
            ToolbarItem {
                Button {
                    vm.messages.removeAll()
                } label: {
                    Label("Clear", systemImage: "trash")
                }
                .disabled(vm.messages.isEmpty)
            }
        }
    }

    @ViewBuilder
    private func messageRow(
        text: String,
        image: String,
        label: String,
        responseError: String? = nil,
        showLoading: Bool = false,
        onRetry: (() -> Void)? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(image)
                    .resizable()
                    .frame(width: 24, height: 24)

                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Text(text)
                .font(.system(size: 16))
                .textSelection(.enabled)
                .lineSpacing(4)

            if let error = responseError {
                Text("Error: \(error)")
                    .font(.system(size: 14))
                    .foregroundStyle(.red)
                    .padding(.top, 4)

                Button("Retry") {
                    onRetry?()
                }
                .buttonStyle(.bordered)
            }

            if showLoading {
                LoadingView(color: .BETRAYED)
                    .frame(height: 10)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func sendMessage() {
        guard !vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        Task {
            await vm.sendTapped()
        }
    }
}
