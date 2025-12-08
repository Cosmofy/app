//
//  Typography.swift
//  Cosmofy
//
//  A single source of truth for all typography in the app.
//  Uses Apple's naming convention with platform-specific sizes.
//

import SwiftUI

// MARK: - Platform Font Sizes

/// Font sizes using Apple's naming, but with custom values per platform
enum AppFontSize {
    case caption2
    case caption
    case footnote
    case subheadline
    case body
    case headline
    case title3
    case title2
    case title
    case largeTitle

    var value: CGFloat {
        #if os(watchOS)
        switch self {
        case .caption2:     return 9
        case .caption:      return 10
        case .footnote:     return 11
        case .subheadline:  return 12
        case .body:         return 13
        case .headline:     return 14
        case .title3:       return 16
        case .title2:       return 18
        case .title:        return 20
        case .largeTitle:   return 24
        }
        #elseif os(tvOS)
        switch self {
        case .caption2:     return 18
        case .caption:      return 22
        case .footnote:     return 24
        case .subheadline:  return 26
        case .body:         return 28
        case .headline:     return 32
        case .title3:       return 38
        case .title2:       return 48
        case .title:        return 56
        case .largeTitle:   return 72
        }
        #elseif os(visionOS)
        switch self {
        case .caption2:     return 17
        case .caption:      return 19
        case .footnote:     return 21
        case .subheadline:  return 23
        case .body:         return 25
        case .headline:     return 25
        case .title3:       return 30
        case .title2:       return 34
        case .title:        return 42
        case .largeTitle:   return 50
        }
        #elseif os(macOS)
        switch self {
        case .caption2:     return 10
        case .caption:      return 12
        case .footnote:     return 13
        case .subheadline:  return 14
        case .body:         return 16
        case .headline:     return 18
        case .title3:       return 22
        case .title2:       return 28
        case .title:        return 34
        case .largeTitle:   return 42
        }
        #else // iOS/iPadOS
        switch self {
        case .caption2:     return 11
        case .caption:      return 12
        case .footnote:     return 13
        case .subheadline:  return 15
        case .body:         return 17
        case .headline:     return 17
        case .title3:       return 20
        case .title2:       return 22
        case .title:        return 28
        case .largeTitle:   return 34
        }
        #endif
    }
}

// MARK: - Design Variants

enum AppFontDesign {
    case rounded
    case serif
    case mono
    case regular

    var swiftUI: Font.Design {
        switch self {
        case .rounded:  return .rounded
        case .serif:    return .serif
        case .mono:     return .monospaced
        case .regular:  return .default
        }
    }
}

// MARK: - Font Weights

enum AppFontWeight {
    case regular
    case medium
    case semibold
    case bold

    var swiftUI: Font.Weight {
        switch self {
        case .regular:  return .regular
        case .medium:   return .medium
        case .semibold: return .semibold
        case .bold:     return .bold
        }
    }
}

// MARK: - Letter Spacing (Tracking)

enum AppTracking: CGFloat {
    case tight   = -0.5
    case snug    = -0.25
    case normal  = 0
    case wide    = 0.5
}

// MARK: - Line Spacing

enum AppLineSpacing: CGFloat {
    case tight   = 2
    case normal  = 4
    case relaxed = 8
}

// MARK: - App Font

/// Platform-aware fonts with Apple naming
/// Usage: Text("Hello").font(AppFont.body)
struct AppFont {

    // MARK: - Rounded (Default UI)

    static var largeTitle: Font {
        .system(size: AppFontSize.largeTitle.value, weight: .bold, design: .rounded)
    }

    static var title: Font {
        .system(size: AppFontSize.title.value, weight: .bold, design: .rounded)
    }

    static var title2: Font {
        .system(size: AppFontSize.title2.value, weight: .semibold, design: .rounded)
    }

    static var title3: Font {
        .system(size: AppFontSize.title3.value, weight: .semibold, design: .rounded)
    }

    static var headline: Font {
        .system(size: AppFontSize.headline.value, weight: .semibold, design: .rounded)
    }

    static var body: Font {
        .system(size: AppFontSize.body.value, weight: .regular, design: .rounded)
    }

    static var subheadline: Font {
        .system(size: AppFontSize.subheadline.value, weight: .regular, design: .rounded)
    }

    static var footnote: Font {
        .system(size: AppFontSize.footnote.value, weight: .regular, design: .rounded)
    }

    static var caption: Font {
        .system(size: AppFontSize.caption.value, weight: .medium, design: .rounded)
    }

    static var caption2: Font {
        .system(size: AppFontSize.caption2.value, weight: .medium, design: .rounded)
    }


    // MARK: - Serif (Descriptions, Articles)

    static var serifBody: Font {
        .system(size: AppFontSize.body.value, weight: .regular, design: .serif)
    }

    static var serifSubheadline: Font {
        .system(size: AppFontSize.subheadline.value, weight: .regular, design: .serif)
    }

    static var serifTitle3: Font {
        .system(size: AppFontSize.title3.value, weight: .regular, design: .serif)
    }


    // MARK: - Custom Builder

    static func custom(
        _ size: AppFontSize,
        weight: AppFontWeight = .regular,
        design: AppFontDesign = .rounded
    ) -> Font {
        .system(size: size.value, weight: weight.swiftUI, design: design.swiftUI)
    }
}

// MARK: - Custom Font Modifier

extension View {

    /// Usage:
    ///   Text("Hello").cfont(.body)           // rounded (default), tighter tracking
    ///   Text("Hello").cfont(.body, .serif)   // serif
    ///   Text("Hello").cfont(.body, .mono)    // monospaced
    ///   Text("Hello").cfont(.body, .regular) // system default
    func cfont(_ size: AppFontSize, _ design: AppFontDesign = .rounded, weight: AppFontWeight = .regular) -> some View {
        let font = Font.system(size: size.value, weight: weight.swiftUI, design: design.swiftUI)

        // Rounded gets tighter letter spacing
        if design == .rounded {
            return AnyView(self.font(font).tracking(AppTracking.snug.rawValue))
        } else {
            return AnyView(self.font(font))
        }
    }
}

// MARK: - View Modifiers

extension View {

    func tightTracking() -> some View {
        self.tracking(AppTracking.tight.rawValue)
    }

    func snugTracking() -> some View {
        self.tracking(AppTracking.snug.rawValue)
    }

    func wideTracking() -> some View {
        self.tracking(AppTracking.wide.rawValue)
    }

    /// Section label style: uppercase, secondary, wide tracking
    func sectionLabelStyle() -> some View {
        self
            .font(AppFont.subheadline)
            .textCase(.uppercase)
            .foregroundColor(.secondary)
            .tracking(AppTracking.wide.rawValue)
    }

    /// Description style: serif, optionally italic
    func descriptionStyle(isItalic: Bool = false) -> some View {
        self
            .font(AppFont.serifBody)
            .conditionalItalic(isItalic)
    }
}

// MARK: - Italic Helper

extension View {
    @ViewBuilder
    func conditionalItalic(_ isItalic: Bool) -> some View {
        if isItalic {
            self.italic()
        } else {
            self
        }
    }
}

// MARK: - Reference
/*

 SIZES PER PLATFORM:
 ┌─────────────┬───────┬───────┬───────┬──────────┬─────────┐
 │    Size     │  iOS  │ macOS │ tvOS  │ visionOS │ watchOS │
 ├─────────────┼───────┼───────┼───────┼──────────┼─────────┤
 │ caption2    │  11   │  10   │  18   │    17    │    9    │
 │ caption     │  12   │  12   │  22   │    19    │   10    │
 │ footnote    │  13   │  13   │  24   │    21    │   11    │
 │ subheadline │  15   │  14   │  26   │    23    │   12    │
 │ body        │  17   │  16   │  28   │    25    │   13    │
 │ headline    │  17   │  18   │  32   │    25    │   14    │
 │ title3      │  20   │  22   │  38   │    30    │   16    │
 │ title2      │  22   │  28   │  48   │    34    │   18    │
 │ title       │  28   │  34   │  56   │    42    │   20    │
 │ largeTitle  │  34   │  42   │  72   │    50    │   24    │
 └─────────────┴───────┴───────┴───────┴──────────┴─────────┘

 USAGE:
    Text("Hello").cfont(.body)                      // rounded (default)
    Text("Hello").cfont(.body, .serif)              // serif
    Text("Hello").cfont(.body, .mono)               // monospaced
    Text("Hello").cfont(.body, .regular)            // system default
    Text("Hello").cfont(.title, weight: .bold)      // with weight

*/
