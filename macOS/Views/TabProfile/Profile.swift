//
//  Profile.swift
//  Cosmofy macOS
//
//  Created by Arryan Bhatnagar on 8/2/24.
//

import SwiftUI

struct Profile: View {
    @Environment(\.colorScheme) private var scheme
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    @Namespace private var animation
    @State private var circleOffset: CGSize = .zero

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Theme selector
                    themeSelector

                    // Profile card
                    profileCard
                }
                .padding()
            }
            .navigationTitle("Profile")
        }
        .onAppear {
            let isDark = scheme == .dark
            circleOffset = CGSize(width: isDark ? 30 : 150, height: isDark ? -25 : -150)
        }
        .onChange(of: scheme) { _, newValue in
            let isDark = newValue == .dark
            withAnimation(.bouncy) {
                circleOffset = CGSize(width: isDark ? 30 : 150, height: isDark ? -25 : -150)
            }
        }
    }

    private var themeSelector: some View {
        VStack(spacing: 15) {
            Circle()
                .fill(userTheme.color(scheme).gradient)
                .frame(width: 150, height: 150)
                .mask {
                    Rectangle()
                        .overlay {
                            Circle()
                                .offset(circleOffset)
                                .blendMode(.destinationOut)
                        }
                }

            HStack(spacing: 0) {
                ForEach(Theme.allCases, id: \.rawValue) { theme in
                    Text(theme.rawValue)
                        .font(.body)
                        .fontDesign(.rounded)
                        .padding(.vertical, 10)
                        .frame(width: 100)
                        .background {
                            ZStack {
                                if userTheme == theme {
                                    Capsule()
                                        .fill(.themeBG)
                                        .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                                }
                            }
                            .animation(.snappy, value: userTheme)
                        }
                        .contentShape(.rect)
                        .onTapGesture {
                            userTheme = theme
                        }
                }
            }
            .padding(3)
            .background(.primary.opacity(0.06), in: .capsule)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Stellar Scholar")
                    .fontDesign(.rounded)
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                HStack {
                    Text("Active")
                        .foregroundStyle(.green)
                        .fontDesign(.rounded)
                        .fontWeight(.medium)
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            Text("Intermediate knowledge of space, perfect for curious minds.")
                .foregroundStyle(.secondary)
                .fontDesign(.rounded)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    Profile()
}

// MARK: - Theme

enum Theme: String, CaseIterable {
    case systemDefault = "Default"
    case light = "Light"
    case dark = "Dark"

    func color(_ scheme: ColorScheme) -> Color {
        switch self {
        case .systemDefault:
            return scheme == .dark ? .moon : .sun
        case .light:
            return .sun
        case .dark:
            return .moon
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .systemDefault:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
