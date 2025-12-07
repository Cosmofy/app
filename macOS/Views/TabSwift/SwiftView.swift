//  ========================================
//  ContentView.swift
//  Cosmofy
//  4th Edition
//  Created by Arryan Bhatnagar on 10/24/23.
//  Abstract: SwiftUI view of SwiftViewController.
//  ========================================

import SwiftUI
import TipKit

struct SwiftView: View {

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: InteractingViewModel
    @State private var userTouched = false
    @FocusState var isTextFieldFocused: Bool
    @State private var hasAppeared = false
    
    var body: some View {
        NavigationStack {
            VStack {
                chatListView
            }
            
            #if !os(tvOS)
            .navigationTitle("Swift")
            #endif
            #if os(iOS)
            .onAppear {
                UINavigationBar.appearance().largeTitleTextAttributes = [
                    .font: UIFont(name: "SF Pro Rounded Bold", size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .semibold),
                ]
            }
            #endif
        }
    }
    
    var chatListView: some View {
        ScrollViewReader { proxy in
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(vm.messages) { message in
                                MessageRowView(message: message) { message in
                                    Task { @MainActor in await vm.retry(message: message) }
                                }
                                .frame(width: geometry.size.width) // Set full width
                            }
                        }
                        // Detect if the user touches or scrolls in the view
//                        .gesture(
//                            DragGesture().onChanged { _ in
//                                userTouched = true // Stop auto-scrolling on user interaction
//
//                            }
//                        )
                    }
                    .onTapGesture {
                        isTextFieldFocused = false
                        userTouched = true // Stop auto-scrolling on user interaction
                    }
                    .onChange(of: vm.messages.last?.responseText) { oldValue, newValue in
                        if !userTouched { // Only auto-scroll if user hasn't interacted
                            scrollToBottom(proxy: proxy)
                        }
                    }

                    bottomView(image: "user", proxy: proxy)

                    Spacer()
                }
            }
        }
        #if !os(tvOS)
        .background(colorScheme == .light ? .white : Color(.black))
        #endif
        
    }


    
    func bottomView(image: String, proxy: ScrollViewProxy) -> some View {
        HStack(alignment: .top, spacing: 8) {
            
            HStack {
                
                if image.hasPrefix("http"), let url = URL(string: image) {
                    AsyncImage(url: url) {
                        image in image
                            .resizable()
                            .frame(width: 30, height: 30)
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(image)
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                 
                
//                if AES_Complete {
//                    Image(systemName: "livephoto")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .foregroundColor(.green)
//                } else {
//                    Image(systemName: "livephoto")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .foregroundColor(.red)
//                }

                TextField("Ask away...", text: $vm.inputMessage, axis: .vertical)
                #if os(iOS)
                
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                #endif
                    .focused($isTextFieldFocused)
                    .disabled(vm.isInteractingWithChatGPT)
            
                if vm.isInteractingWithChatGPT {
                    Button {
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .tint(.red)
                    }
                } else {
                    Button {
                        Task {
                            @MainActor in
                            isTextFieldFocused = false
                            userTouched = false
//                            tip.invalidate(reason: .actionPerformed)
                            scrollToBottom(proxy: proxy)
                            await vm.sendTapped()
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .tint(.SOUR)
                    }
                    .disabled(vm.inputMessage
                        .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            }
            .padding()
            .cornerRadius(10)
        }
//        .padding(.horizontal, 16)
//        .padding(.top, 12)
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

#Preview {
    SwiftView()
        .environmentObject(InteractingViewModel(api: API()))
}
