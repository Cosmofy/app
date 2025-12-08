//
//  SwiftView.swift
//  Cosmofy
//
//  Shared Livia chat view across all platforms
//

import SwiftUI

struct SwiftView: View {
    @Environment(\.colorScheme) var colorScheme

    @StateObject var vm = InteractingViewModel(api: API())

    @State private var userTouched = false
    @FocusState var isTextFieldFocused: Bool
    @State private var hasAppeared = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                chatListView
                #if os(watchOS)
                .edgesIgnoringSafeArea(.horizontal)
                #endif
            }
            #if !os(tvOS)
            .navigationTitle("Livia")
            #endif
            #if os(iOS) || os(watchOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            #if os(watchOS)
            .ignoresSafeArea(edges: .bottom)
            #endif
        }
    }

    var chatListView: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(vm.messages) { message in
                            MessageRowView(message: message) { message in
                                Task { @MainActor in
                                    await vm.retry(message: message)
                                }
                            }
                        }
                        #if os(iOS)
                        .gesture(
                            DragGesture()
                                .onChanged { _ in
                                    userTouched = true
                                }
                        )
                        #endif
                    }
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                    #if os(macOS)
                    .padding(.horizontal)
                    #endif
                }
                .onTapGesture {
                    isTextFieldFocused = false
                    #if os(tvOS)
                    userTouched = true
                    #endif
                }
                .onChange(of: vm.messages.last?.responseText) { oldValue, newValue in
                    if !userTouched {
                        scrollToBottom(proxy: proxy)
                    }
                }

                #if os(macOS)
                Divider()
                #endif

                bottomView(proxy: proxy)
                    #if os(watchOS)
                    .frame(height: 50)
                    #elseif os(tvOS)
                    .frame(maxHeight: 80)
                    #endif

                #if os(tvOS)
                Spacer()
                #endif
            }
        }
    }

    func bottomView(proxy: ScrollViewProxy) -> some View {
        HStack(alignment: .top, spacing: platformInputSpacing) {
            #if os(macOS)
            Image("user")
                .resizable()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            #endif

            #if os(macOS)
            TextField("Ask away...", text: $vm.inputMessage, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .focused($isTextFieldFocused)
                .disabled(vm.isInteractingWithChatGPT)
                .onSubmit {
                    submitMessage(proxy: proxy)
                }
            #else
            HStack {
                #if os(watchOS)
                TextField("Ask away", text: $vm.inputMessage, axis: .vertical)
                    .focused($isTextFieldFocused)
                    .disabled(vm.isInteractingWithChatGPT)
                    .frame(maxWidth: 100, maxHeight: 20)
                #else
                TextField("Ask away...", text: $vm.inputMessage, axis: .vertical)
                    .focused($isTextFieldFocused)
                    .disabled(vm.isInteractingWithChatGPT)
                #endif

                if vm.isInteractingWithChatGPT {
                    #if os(watchOS)
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.red)
                        .frame(width: 30, height: 30)
                    #elseif os(tvOS)
                    Button { } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .tint(.red)
                    }
                    #else
                    ProgressView()
                        .frame(width: 30, height: 30)
                    #endif
                } else {
                    Button {
                        Task { @MainActor in
                            isTextFieldFocused = false
                            userTouched = false
                            scrollToBottom(proxy: proxy)
                            await vm.sendTapped()
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: sendButtonSize))
                            .foregroundStyle(.SOUR)
                    }
                    .disabled(vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    #if os(watchOS)
                    .frame(width: 30, height: 30)
                    #endif
                }
            }
            #if !os(watchOS)
            .padding()
            .cornerRadius(10)
            #endif
            #endif

            #if os(macOS)
            if vm.isInteractingWithChatGPT {
                ProgressView()
                    .frame(width: 32, height: 32)
            } else {
                Button {
                    Task { @MainActor in
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
            #endif
        }
        #if os(macOS)
        .padding()
        #elseif os(watchOS)
        .padding(.horizontal)
        #endif
    }

    private func submitMessage(proxy: ScrollViewProxy) {
        if !vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Task { @MainActor in
                isTextFieldFocused = false
                userTouched = false
                scrollToBottom(proxy: proxy)
                await vm.sendTapped()
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = vm.messages.last?.id else { return }
        withAnimation {
            proxy.scrollTo(id, anchor: .bottomTrailing)
        }
    }

    // MARK: - Platform values

    private var platformInputSpacing: CGFloat {
        #if os(macOS)
        return 12
        #else
        return 8
        #endif
    }

    private var sendButtonSize: CGFloat {
        #if os(watchOS)
        return 20
        #elseif os(tvOS)
        return 30
        #elseif os(macOS)
        return 32
        #else
        return 30
        #endif
    }
}

#Preview {
    SwiftView()
}
