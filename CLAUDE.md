# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Cosmofy is a multi-platform SwiftUI application for exploring the solar system. It features 3D planet models, planetary data, an AI space assistant ("Swift"), NASA's Astronomy Picture of the Day, and real-time natural event tracking via Nature Scope.

## Build Commands

Open `Cosmofy.xcodeproj` in Xcode. The project contains four targets:
- **Cosmofy** (iOS/iPadOS) - Primary target
- **Cosmofy macOS** - macOS app with sidebar navigation
- **Cosmofy tvOS** - Apple TV app
- **Cosmofy watchOS** - Apple Watch app

Build and run using Xcode's standard workflow (Cmd+R) or via command line:
```bash
xcodebuild -project Cosmofy.xcodeproj -scheme "Cosmofy" -destination "platform=iOS Simulator,name=iPhone 15"
```

## Architecture

### Platform-Specific Code
Each platform has its own directory with platform-specific implementations:
- `iOS/` - iPhone/iPad views including adaptive layouts (`iPadPlanetsView`, `iPadHome`)
- `macOS/` - Mac-specific views with Settings support
- `tvOS/` - Apple TV optimized views
- `watchOS/` - Watch-specific compact views

### Shared Code (`Shared/`)
Cross-platform code shared by all targets:
- `Livia/` - Backend communication layer:
  - `Client.swift` - GraphQL client (singleton `GraphQLClient.shared`)
  - `Queries.swift` - GraphQL query definitions
  - `Models.swift` - Decodable response types (prefixed with `GQL`)
  - `GQLViewModel.swift` - Main data layer (`@MainActor`, fetches all data on init)
  - `API_OPENAI.swift` - AI chat integration (`InteractingViewModel`, `API` class)
- `Models/` - Local data models (e.g., `Planet.swift` with hardcoded planet data)
- `Extensions/` - SwiftUI view extensions
- `Helpers/` - Utility code including `PlanetNode.swift` for 3D rendering

### Data Flow
1. App launches with splash screen (`SplashScreen` in iOS `CosmofyApp.swift`)
2. `GQLViewModel` fetches all data from backend (`https://livia.arryan.xyz/graphql`)
3. On success, navigates to `IntroView` → `TabBarView`
4. On failure, shows `NetworkErrorView` with health check polling

### Key ViewModels
- `GQLViewModel` - Central data store for GraphQL data (picture, articles, events, planets)
- `InteractingViewModel` - Manages AI chat state with streaming responses

### Backend Integration
The app communicates with a GraphQL backend at `https://livia.arryan.xyz`:
- `/graphql` - GraphQL endpoint for data queries
- `/chat/completions` - LiteLLM proxy for AI chat
- `/health` - Health check endpoint

## Dependencies (Swift Package Manager)
- `swift-markdown-ui` - Markdown rendering
- `SwiftfulLoadingIndicators` - Loading animations
- `swiftui-vertical-tab-view` - Vertical tab navigation
- `NetworkImage` - Async image loading
- `Zoomable` - Image zoom gestures

## Code Conventions
- GraphQL response types use `GQL` prefix (e.g., `GQLPlanet`, `GQLEvent`)
- Local/static planet data defined in `Shared/Models/TabPlanets/Planet.swift`
- iOS uses conditional layouts based on `UIDevice.current.userInterfaceIdiom`
- Platform-specific code uses `#if os(...)` conditionals
