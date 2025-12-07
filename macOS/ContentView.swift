//
//  ContentView.swift
//  Cosmofy macOS
//
//  This file contains TabBarView, Profile, IntroView, OnboardingView, and Kids views
//

import SwiftUI

// MARK: - TabBarView

struct TabBarView: View {

    @ObservedObject var gqlViewModel: GQLViewModel
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Home(viewModel: gqlViewModel)
                .tabItem {
                    Label("Home", image: "tab-bar-home")
                }
                .tag(0)

            PlanetsView(viewModel: gqlViewModel)
                .tabItem {
                    Label("Planets", image: "tab-bar-planets")
                }
                .tag(1)

            SwiftView()
                .tabItem {
                    Label("Livia", image: "tab-bar-livia")
                }
                .tag(2)
        }
        .tint(.primary)
    }
}

struct TabBarKids: View {
    @ObservedObject var gqlViewModel: GQLViewModel

    var body: some View {
        TabView {
            Learn(gqlViewModel: gqlViewModel)
                .tabItem {
                    Image(systemName: "house")
                    Text("Learn")
                }
                .tag(0)

            Profile()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(1)
        }
        .tint(.primary)
    }
}

// MARK: - IntroView

struct IntroView: View {

    @AppStorage("signed_in") var currentUserSignedIn: Bool = false
    @AppStorage("selectedProfile") var currentSelectedProfile: Int?
    @ObservedObject var gqlViewModel: GQLViewModel

    var tranition: AnyTransition = .opacity

    var body: some View {
        VStack {
            if currentUserSignedIn {
                switch currentSelectedProfile {
                case 1:
                    TabBarKids(gqlViewModel: gqlViewModel)
                        .transition(tranition)
                case 2:
                    TabBarView(gqlViewModel: gqlViewModel)
                        .transition(tranition)
                default:
                    TabBarView(gqlViewModel: gqlViewModel)
                        .transition(tranition)
                }
            } else {
                OnboardingView()
                    .transition(tranition)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: currentUserSignedIn)
        .animation(.easeInOut(duration: 0.5), value: currentSelectedProfile)
    }
}

// MARK: - OnboardingView

struct OnboardingView: View {

    @State var onboardingState: Int = 0
    @State var selectedProfile: Int = 2
    @State var firstName: String = ""

    let transition: AnyTransition = .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))

    @AppStorage("selectedProfile") var currentSelectedProfile: Int?
    @AppStorage("firstName") var currentFirstName: String?
    @AppStorage("signed_in") var currentUserSignedIn: Bool = false

    @State var showAlert: Bool = false

    var body: some View {
        VStack {
            switch onboardingState {
            case 0:
                welcomeScreen
                    .transition(transition)
            case 1:
                aboutScreen
                    .transition(transition)
            case 2:
                roleSelectionScreen
                    .transition(transition)
            case 3:
                nameScreen
                    .transition(transition)
            default:
                VStack {
                    Spacer()
                    Text("You should not see this")
                    Spacer()
                }
            }

            Spacer()
            bottomButton
        }
        .padding()
    }

    private var bottomButton: some View {
        Text(
            onboardingState == 0 ? "Continue" :
            onboardingState == 3 ? "Get Started" : "Next"
        )
        .font(.headline)
        .foregroundStyle(.white)
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(.green.gradient)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
        .onTapGesture {
            handleNextButtonPress()
        }
    }

    private var welcomeScreen: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                HStack {
                    Text("Welcome to")
                        .fontDesign(.rounded)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                HStack {
                    Text("Cosmofy.")
                        .fontDesign(.rounded)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    Spacer()
                }
            }
            Spacer()
        }
    }

    private var aboutScreen: some View {
        VStack {
            Spacer()
            HStack() {
                Text("What is Cosmofy?")
                    .fontDesign(.rounded)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()

            HStack() {
                Text("Cosmofy is a multi-platfrom application about astronomy and space.")
                    .fontDesign(.rounded)
                    .fontWeight(.regular)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.horizontal)
            Spacer()
        }
    }

    private var roleSelectionScreen: some View {
        VStack {
            Spacer()
            HStack() {
                Text("Which Profile Suits You?")
                    .fontDesign(.rounded)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }

            VStack {
                HStack() {
                    Text("Stellar Scholar")
                        .fontDesign(.rounded)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    if selectedProfile == 2 {
                        HStack {
                            Text("Default")
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
                        .foregroundStyle(.secondary)
                        .fontDesign(.rounded)
                    Spacer()
                }
                .padding(.horizontal)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay {
                if selectedProfile == 2 {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.green.gradient, lineWidth: 2)
                }
            }
            .padding(.bottom)
            .onTapGesture {
                selectedProfile = 2
            }

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
                        .foregroundStyle(.secondary)
                        .fontDesign(.rounded)
                    Spacer()
                }
                .padding(.horizontal)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay {
                if selectedProfile == 1 {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.green.gradient, lineWidth: 2)
                }
            }
            .onTapGesture {
                selectedProfile = 1
            }

            Text("You can change this later.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fontDesign(.rounded)
                .padding()
            Spacer()
        }
        .padding(.horizontal)
    }

    private var nameScreen: some View {
        VStack {
            Spacer()
            Text("Who are you?")
                .fontDesign(.rounded)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            TextField("First Name", text: $firstName)
                .fontDesign(.rounded)
                .frame(height: 50)
                .padding(.horizontal)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)

            if showAlert {
                Text("Your name should at least be 2 characters.")
                    .foregroundStyle(.red)
                    .font(.caption)
                    .fontDesign(.rounded)
                    .padding(.top)
            } else {
                Text(" ")
                    .foregroundStyle(.red)
                    .font(.caption)
                    .fontDesign(.rounded)
                    .padding(.top, 8)
            }
            Spacer()
        }
    }

    func handleNextButtonPress() {
        switch onboardingState {
            case 3:
                guard firstName.count >= 2 else {
                    showAlert = true
                    return
                }
            default: break
        }

        if onboardingState == 3 {
            signIn()
        } else {
            withAnimation(.spring()) {
                onboardingState += 1
            }
        }
    }

    func signIn() {
        currentSelectedProfile = selectedProfile
        currentFirstName = firstName
        withAnimation(.spring()) {
            currentUserSignedIn = true
        }
    }
}

// MARK: - Profile

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
    }
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
        .environment(\.colorScheme, scheme)
        .onChange(of: scheme, initial: false) { _, newValue in
            let isDark = newValue == .dark
            withAnimation(.bouncy) {
                circleOffset = CGSize(width: isDark ? 30 : 150, height: isDark ? -25 : -150)
            }
        }
    }
}

// Theme enum
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

// MARK: - Kids Views

struct Learn: View {
    @ObservedObject var gqlViewModel: GQLViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(gqlViewModel.planets, id: \.name) { planet in
                        NavigationLink(destination: KidsPlanetView(planet: planet)) {
                            HStack(spacing: 16) {
                                Image(planetImageName(for: planet.name ?? ""))
                                    .resizable()
                                    .frame(width: 60, height: 60)

                                VStack(alignment: .leading) {
                                    Text(planet.name ?? "Unknown")
                                        .font(.title2)
                                        .fontDesign(.rounded)
                                        .fontWeight(.semibold)

                                    Text(planet.description ?? "")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Learn")
        }
    }

    func planetImageName(for name: String) -> String {
        switch name.lowercased() {
        case "mercury": return "smiling-mercury"
        case "venus": return "smiling-venus"
        case "earth": return "smiling-earth"
        case "mars": return "smiling-mars"
        case "jupiter": return "smiling-jupiter"
        case "saturn": return "smiling-saturn"
        case "uranus": return "smiling-uranus"
        case "neptune": return "smiling-neptune"
        default: return "smiling-earth"
        }
    }
}

struct KidsPlanetView: View {
    let planet: GQLPlanet

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(planetImageName(for: planet.name ?? ""))
                    .resizable()
                    .frame(width: 150, height: 150)

                Text(planet.name ?? "Unknown")
                    .font(.largeTitle)
                    .fontDesign(.rounded)
                    .fontWeight(.bold)

                Text(planet.expandedDescription ?? planet.description ?? "")
                    .font(.body)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if let facts = planet.facts, !facts.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Fun Facts!")
                            .font(.title2)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)

                        ForEach(facts, id: \.self) { fact in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                Text(fact)
                                    .fontDesign(.rounded)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .navigationTitle(planet.name ?? "Planet")
    }

    func planetImageName(for name: String) -> String {
        switch name.lowercased() {
        case "mercury": return "smiling-mercury"
        case "venus": return "smiling-venus"
        case "earth": return "smiling-earth"
        case "mars": return "smiling-mars"
        case "jupiter": return "smiling-jupiter"
        case "saturn": return "smiling-saturn"
        case "uranus": return "smiling-uranus"
        case "neptune": return "smiling-neptune"
        default: return "smiling-earth"
        }
    }
}

// MARK: - MessageRowView

struct MessageRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    let message: MessageRow
    let retryCallback: (MessageRow) -> Void

    // Check if this is the initial greeting from Swift (sendImage is "openai" or "swift")
    var isSwiftGreeting: Bool {
        message.sendImage == "openai" || message.sendImage == "livia"
    }

    var body: some View {
        VStack(spacing: 12) {
            // First message - check if it's from Swift or User
            if isSwiftGreeting {
                // Swift's greeting message
                aiMessageRow(text: message.sendText, responseError: nil, showDotLoading: false)
            } else {
                // User message
                userMessageRow(text: message.sendText)
            }

            // AI Response
            if let text = message.responseText {
                aiMessageRow(text: text, responseError: message.responseError, showDotLoading: message.isInteractingWithChatGPT)
            } else if message.isInteractingWithChatGPT && !isSwiftGreeting {
                aiLoadingRow()
            }
        }
        .padding(.vertical, 8)
    }

    // User message - aligned right with box
    func userMessageRow(text: String) -> some View {
        HStack {
            Spacer(minLength: UIConstants.messageMaxWidthPadding)

            HStack(alignment: .center, spacing: 12) {
                Text(text)
                    .font(.title3)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.trailing)
                    .padding(16)
                    .background(Color.SOUR.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                Image("user")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
            }
        }
    }

    // AI loading state
    func aiLoadingRow() -> some View {
        HStack {
            HStack(alignment: .center, spacing: 12) {
                Image("livia")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)

                LoadingView(color: .BETRAYED)
                    .frame(height: 12)
                    .frame(width: 50)
                    .padding(16)
                    .background(colorScheme == .light ? Color.gray.opacity(0.1) : Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }

            Spacer()
        }
    }

    // AI message - aligned left with box
    func aiMessageRow(text: String, responseError: String? = nil, showDotLoading: Bool = false) -> some View {
        HStack {
            HStack(alignment: .center, spacing: 12) {
                Image("livia")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 0) {
                    Text(text)
                        .font(.title3)
                        .fontDesign(.rounded)
                        .multilineTextAlignment(.leading)
                        .textSelection(.enabled)

                    if let error = responseError {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 8)

                        Button("Regenerate Response") {
                            retryCallback(message)
                        }
                        .foregroundColor(.blue)
                        .padding(.top)
                    }

                    if showDotLoading {
                        LoadingView(color: .BETRAYED)
                            .frame(height: 12)
                            .padding(.top, 8)
                    }
                }
                .padding(16)
                .background(colorScheme == .light ? Color.gray.opacity(0.1) : Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }

            Spacer(minLength: UIConstants.messageMaxWidthPadding)
        }
    }
}

// MARK: - UI Constants

private enum UIConstants {
    static let messageMaxWidthPadding: CGFloat = 150
}

