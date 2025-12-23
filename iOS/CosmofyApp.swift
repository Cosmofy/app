#if swift(>=5.9)
//
//  CosmofyApp.swift
//  Cosmofy
//
//  Created by Arryan Bhatnagar on 3/9/24.
//

import Foundation
import SwiftUI
// import SwiftfulLoadingIndicators // Removed for iOS 9 compatibility

@available(iOS 17.0, *)
struct CosmofyApp: App {
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault

    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .preferredColorScheme(userTheme.colorScheme)

        }
    }
}

@available(iOS 17.0, *)
struct SplashScreen: View {
    @StateObject var gqlViewModel = GQLViewModel()
    @StateObject var swiftViewModel = InteractingViewModel(api: API())

    @State private var showSplash = true
    @AppStorage("selectedProfile") var currentSelectedProfile: Int?
    @AppStorage("signed_in") var currentUserSignedIn: Bool = false
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else if !gqlViewModel.hasLoadedData {
                NetworkErrorView(isLoading: gqlViewModel.isLoading) {
                    Task {
                        await gqlViewModel.fetchAllData()
                    }
                }
            } else {
                IntroView(gqlViewModel: gqlViewModel)
                    .environmentObject(swiftViewModel)
            }
        }
        .preferredColorScheme(userTheme.colorScheme)
    }
}

@available(iOS 17.0, *)
struct NetworkErrorView: View {
    var isLoading: Bool
    var onRetry: () -> Void

    @State private var healthCheckTask: Task<Void, Never>?

    private let healthEndpoint = "https://livia.arryan.xyz/health"

    var body: some View {
        VStack(spacing: 20) {
            Text(isLoading ? "Connecting..." : "Can't connect to server")
                .font(.title2)
                .fontDesign(.rounded)
                .fontWeight(.medium)

            // LoadingIndicator(animation: .threeBallsTriangle, color: .BETRAYED, size: .medium) // Removed for iOS 9 compatibility
            ProgressView()
                .frame(height: 50)

            Button(action: onRetry) {
                Text("Try Again")
                    .fontDesign(.rounded)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .opacity(isLoading ? 0 : 1)
            .disabled(isLoading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            startHealthCheck()
        }
        .onDisappear {
            healthCheckTask?.cancel()
        }
    }

    private func startHealthCheck() {
        healthCheckTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                if Task.isCancelled || isLoading { continue }

                // Ping health endpoint
                if let url = URL(string: healthEndpoint) {
                    do {
                        let (_, response) = try await URLSession.shared.data(from: url)
                        if let httpResponse = response as? HTTPURLResponse,
                           httpResponse.statusCode == 200 {
                            // Server is up, trigger full data fetch
                            await MainActor.run {
                                onRetry()
                            }
                        }
                    } catch {
                        // Server still down, continue polling
                    }
                }
            }
        }
    }
}

@available(iOS 17.0, *)
struct SplashScreenView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: 0xD2DFF7),
                    Color(hex: 0xE1E8F4),
                    Color(hex: 0xC8D5F1),
                    Color(hex: 0xB7C5F4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            Image("app-icon-4k")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 64, height: 64)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
#endif
