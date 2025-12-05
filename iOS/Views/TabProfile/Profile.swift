//
//  Profile.swift
//  Cosmofy iOS
//
//  Created by Arryan Bhatnagar on 8/2/24.
//

import SwiftUI

struct Profile: View {
    @AppStorage("selectedProfile") var selectedProfile: Int?
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        
        NavigationStack {
            ScrollView {
                
                ThemeChangeView(scheme: scheme)
                    .padding(.vertical)
                
                VStack(spacing: 0) {
                                        
                    VStack {
                        HStack() {
                            Text("Stellar Scholar")
                                .fontDesign(.rounded)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            if selectedProfile == 2 {
                                HStack {
                                    Text("Selected")
                                        .foregroundStyle(.green)
                                        .fontDesign(.rounded)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                        .padding()
                        HStack() {
                            Text("Intermediate knowledge of space, perfect for curious minds.")
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(.secondary)
                                .fontDesign(.rounded)
                            Spacer()
                        }
                        .padding(.horizontal)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 130)
                    .background(.ultraThinMaterial)
                    .onTapGesture {
                        selectedProfile = 2
                    }

                    Divider()
                    
                    VStack {
                        HStack() {
                            Text("kids")
                                .foregroundStyle(Color(hex: 0xFAF42A))
                                .fontDesign(.rounded)
                                .font(.title2)
                                .frame(width: 70)
                                .fontWeight(.semibold)
                                .background(
                                    VStack(spacing: 0) {
                                        Rectangle().fill(Color.pink.opacity(0.8).gradient)
                                        Rectangle().fill(Color.purple.opacity(0.8).gradient)
                                        Rectangle().fill(Color.blue.opacity(0.8).gradient)
                                        Rectangle().fill(Color.green.opacity(0.8).gradient)
                                    }
                                    .frame(width: 80, height: 80)
                                    .rotationEffect(.degrees(45))
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .clipped()
                            Spacer()
                            if selectedProfile == 1 {
                                HStack {
                                    Text("Selected")
                                        .foregroundStyle(.green)
                                        .fontDesign(.rounded)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                        .padding()
                        HStack() {
                            Text("Basic introduction to space concepts for young learners.")
                                .multilineTextAlignment(.leading)

                                .foregroundStyle(.secondary)
                                .fontDesign(.rounded)
                            Spacer()
                        }
                        .padding(.horizontal)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 130)
                    .background(.ultraThinMaterial)
                    .onTapGesture {
                        selectedProfile = 1
                    }
                    
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding()
                
                
                
                Spacer()
                
            }
            
            .navigationTitle("Profile")
        }
        .onAppear {
            UINavigationBar.appearance().largeTitleTextAttributes = [
                .font: UIFont(name: "SF Pro Rounded Bold", size: 34) ?? UIFont(descriptor: UIFont.systemFont(ofSize: 34, weight: .semibold).fontDescriptor.withDesign(.rounded)!, size: 34),
            ]
        }

    }
    
}

#Preview {
    Profile()
}



struct ThemeChangeView: View {
    var scheme: ColorScheme
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    @Namespace private var animation
    @State private var circleOffset: CGSize
    
    init(scheme: ColorScheme) {
        self.scheme = scheme
        let isDark = scheme == .dark
        self._circleOffset = .init(initialValue: CGSize(width: isDark ? 30 : 150, height: isDark ? -25 : -150))
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Circle()
                .fill(userTheme.color(scheme).gradient)
                .frame(width: 150, height: 150)
                .mask {
                    /// Inverted Mask
                    Rectangle()
                        .overlay {
                            Circle()
                                .offset(circleOffset)
                                .blendMode(.destinationOut)
                        }
                }
            
            /// Custom Segmented Picker
            HStack(spacing: 0) {
                ForEach(Theme.allCases, id: \.rawValue) { theme in
                    Text(theme.rawValue)
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
            .padding(.bottom, 16)
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(.rect(cornerRadius: 30))
        .padding(.horizontal, 15)
        .padding(.bottom, safeArea.bottom == .zero ? 15 : 0)
        .environment(\.colorScheme, scheme)
        .onChange(of: scheme, initial: false) { _, newValue in
            let isDark = newValue == .dark
            withAnimation(.bouncy) {
                circleOffset = CGSize(width: isDark ? 30 : 150, height: isDark ? -25 : -150)
            }
        }
    }
    
    var safeArea: UIEdgeInsets {
        if let safeArea = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets {
            return safeArea
        }
        
        return .zero
    }
}



/// Theme
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
