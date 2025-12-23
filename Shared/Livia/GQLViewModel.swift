#if swift(>=5.9)
//
//  GQLViewModel.swift
//  Cosmofy
//
//  Created by Arryan Bhatnagar on 12/3/24.
//

import SwiftUI
import Combine
#if os(macOS)
import AppKit
#else
import UIKit
#endif

@available(iOS 17.0, *)
@MainActor
class GQLViewModel: ObservableObject {

    // Picture of the Day
    @Published var picture: GQLPicture?
    @Published var pictureError: String?

    #if os(macOS)
    @Published var preloadedAPODImage: NSImage?
    #else
    @Published var preloadedAPODImage: UIImage?
    #endif

    // Articles
    @Published var articles: [GQLArticle] = []

    // Events
    @Published var events: [GQLEvent] = []
    @Published var eventsLoaded: Bool = false
    @Published var eventsFailed: Bool = false

    // Planets
    @Published var planets: [GQLPlanet] = []

    // Loading states
    @Published var isLoading: Bool = false
    @Published var networkError: Bool = false

    var hasLoadedData: Bool {
        return !planets.isEmpty
    }

    init() {
        Task {
            await fetchAllData()
        }
    }

    func fetchAllData() async {
        isLoading = true
        networkError = false

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchPicture() }
            group.addTask { await self.fetchArticles() }
            group.addTask { await self.fetchEvents() }
            group.addTask { await self.fetchPlanets() }
        }

        if picture == nil && planets.isEmpty && events.isEmpty && articles.isEmpty {
            networkError = true
        }

        isLoading = false
    }

    func fetchPicture(for date: String? = nil) async {
        do {
            var variables: [String: Any]? = nil
            if let date = date {
                variables = ["date": date]
            }

            let response: PictureResponse = try await GraphQLClient.shared.execute(
                query: Queries.picture,
                variables: variables
            )
            self.picture = response.picture
            self.pictureError = nil
            await preloadAPODImage()
        } catch {
            self.picture = nil
            self.preloadedAPODImage = nil
            self.pictureError = error.localizedDescription
        }
    }

    private func preloadAPODImage() async {
        guard let picture = picture,
              picture.media_type == "image",
              let mediaUrl = picture.media,
              let url = URL(string: mediaUrl) else {
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            #if os(macOS)
            if let image = NSImage(data: data) {
                self.preloadedAPODImage = image
            }
            #else
            if let image = UIImage(data: data) {
                self.preloadedAPODImage = image
            }
            #endif
        } catch {
            print("Failed to preload APOD image: \(error)")
        }
    }

    func fetchArticles() async {
        do {
            let response: ArticlesResponse = try await GraphQLClient.shared.execute(query: Queries.articles)
            self.articles = response.articles
        } catch {
            print("Articles error: \(error)")
        }
    }

    func fetchEvents(days: Int? = nil) async {
        do {
            var variables: [String: Any]? = nil
            if let days = days {
                variables = ["daysInput": days]
            }

            let response: GQLEventsResponse = try await GraphQLClient.shared.execute(
                query: Queries.events,
                variables: variables
            )
            self.events = response.events
            self.eventsLoaded = true
            self.eventsFailed = false
        } catch {
            print("Events error: \(error)")
            self.eventsFailed = true
            self.eventsLoaded = false
        }
    }

    func fetchPlanets() async {
        do {
            let response: PlanetsResponse = try await GraphQLClient.shared.execute(query: Queries.planets)
            self.planets = response.planets
        } catch {
            print("Planets error: \(error)")
        }
    }
}
#endif
