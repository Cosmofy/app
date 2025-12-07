//
//  MacSwiftView.swift
//  Cosmofy macOS
//
//  Swift AI chat view for macOS
//

import SwiftUI

struct SwiftView: View {

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: InteractingViewModel
    @State private var userTouched = false
    @FocusState var isTextFieldFocused: Bool
    @State private var hasAppeared = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                chatListView
            }
            .navigationTitle("Livia")
        }
    }

    var chatListView: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(vm.messages) { message in
                            MessageRowView(message: message) { message in
                                Task { @MainActor in await vm.retry(message: message) }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .onTapGesture {
                    isTextFieldFocused = false
                    userTouched = true
                }
                .onChange(of: vm.messages.last?.responseText) { oldValue, newValue in
                    if !userTouched {
                        scrollToBottom(proxy: proxy)
                    }
                }

                Divider()

                bottomView(proxy: proxy)
            }
        }
    }

    func bottomView(proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 12) {
            Image("user")
                .resizable()
                .frame(width: 32, height: 32)
                .clipShape(Circle())

            TextField("Ask away...", text: $vm.inputMessage, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .focused($isTextFieldFocused)
                .disabled(vm.isInteractingWithChatGPT)
                .onSubmit {
                    if !vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Task {
                            @MainActor in
                            isTextFieldFocused = false
                            userTouched = false
                            scrollToBottom(proxy: proxy)
                            await vm.sendTapped()
                        }
                    }
                }

            if vm.isInteractingWithChatGPT {
                ProgressView()
                    .frame(width: 32, height: 32)
            } else {
                Button {
                    Task {
                        @MainActor in
                        isTextFieldFocused = false
                        userTouched = false
                        scrollToBottom(proxy: proxy)
                        await vm.sendTapped()
                    }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.SOUR)
                }
                .buttonStyle(.plain)
                .disabled(vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = vm.messages.last?.id else {
            return
        }
        withAnimation {
            proxy.scrollTo(id, anchor: .bottomTrailing)
        }
    }
}
