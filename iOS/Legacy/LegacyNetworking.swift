//
//  LegacyNetworking.swift
//  Cosmofy
//
//  Networking layer for iOS 9-16 Legacy support
//  Fetches: Picture of the Day, Articles, Planets, Events, and Livia Chat
//

import Foundation

// MARK: - Legacy API Client

class LegacyAPI {
    static let shared = LegacyAPI()

    private let graphqlEndpoint = "https://livia.arryan.xyz/graphql"
    private let chatEndpoint = "https://swift.arryan.xyz/v1/chat/completions"
    private let passphrase = "my-phone-passphrase"

    private var liviaApiKey: String?
    private var chatHistory: [[String: String]] = []

    private init() {}

    // MARK: - GraphQL Execute

    private func executeGraphQL<T: Decodable>(
        query: String,
        variables: [String: Any]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: graphqlEndpoint) else {
            completion(.failure(LegacyAPIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = ["query": query]
        if let variables = variables {
            body["variables"] = variables
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(LegacyAPIError.noData))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode else {
                completion(.failure(LegacyAPIError.httpError((response as? HTTPURLResponse)?.statusCode ?? 0)))
                return
            }

            do {
                let graphQLResponse = try JSONDecoder().decode(LegacyGraphQLResponse<T>.self, from: data)
                if let responseData = graphQLResponse.data {
                    completion(.success(responseData))
                } else if let errors = graphQLResponse.errors, !errors.isEmpty {
                    completion(.failure(LegacyAPIError.graphQL(errors.map { $0.message })))
                } else {
                    completion(.failure(LegacyAPIError.noData))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // MARK: - Fetch Picture of the Day

    func fetchPictureOfTheDay(date: String? = nil, completion: @escaping (Result<LegacyPicture, Error>) -> Void) {
        let query = """
            query Picture($date: String) {
                picture(date: $date) {
                    date
                    title
                    credit
                    copyright
                    media
                    media_type
                    explanation {
                        original
                        summarized
                        kids
                    }
                }
            }
        """

        var variables: [String: Any]? = nil
        if let date = date {
            variables = ["date": date]
        }

        executeGraphQL(query: query, variables: variables) { (result: Result<LegacyPictureResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.picture))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Fetch Articles

    func fetchArticles(completion: @escaping (Result<[LegacyArticle], Error>) -> Void) {
        let query = """
            query {
                articles {
                    month
                    year
                    title
                    subtitle
                    url
                    source
                    authors {
                        name
                        title
                        image
                    }
                    banner {
                        image
                        designer
                    }
                }
            }
        """

        executeGraphQL(query: query) { (result: Result<LegacyArticlesResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.articles))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Fetch Planets

    func fetchPlanets(completion: @escaping (Result<[LegacyPlanet], Error>) -> Void) {
        let query = """
            query {
                planets {
                    id
                    name
                    description
                    expandedDescription
                    facts
                    visual
                    moons
                    rings
                    mass
                    volume
                    density
                    temperature
                    escapeVelocity
                    gravityEquatorial
                    radiusEquatorial
                    albedo
                    orbitalVelocity
                    orbitalInclination
                    siderealOrbitPeriodY
                    solarDayLength
                    obliquityToOrbit
                    siderealRotationPeriod
                    flattening
                    pressure
                    atmosphere {
                        name
                        molar
                        formula
                        percentage
                    }
                }
            }
        """

        executeGraphQL(query: query) { (result: Result<LegacyPlanetsResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.planets))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Fetch Events (Nature Scope)

    func fetchEvents(days: Int = 20, completion: @escaping (Result<[LegacyEvent], Error>) -> Void) {
        let query = """
            query Events($daysInput: Int) {
                events(daysInput: $daysInput) {
                    id
                    title
                    categories {
                        id
                        title
                    }
                    sources {
                        id
                        url
                    }
                    geometry {
                        magnitudeValue
                        magnitudeUnit
                        date
                        type
                        coordinates
                    }
                }
            }
        """

        executeGraphQL(query: query, variables: ["daysInput": days]) { (result: Result<LegacyEventsResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.events))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Fetch All Data

    func fetchAllData(completion: @escaping (LegacyPicture?, [LegacyArticle]?, [LegacyPlanet]?, [LegacyEvent]?) -> Void) {
        let group = DispatchGroup()

        var picture: LegacyPicture?
        var articles: [LegacyArticle]?
        var planets: [LegacyPlanet]?
        var events: [LegacyEvent]?

        group.enter()
        fetchPictureOfTheDay { result in
            if case .success(let p) = result { picture = p }
            group.leave()
        }

        group.enter()
        fetchArticles { result in
            if case .success(let a) = result { articles = a }
            group.leave()
        }

        group.enter()
        fetchPlanets { result in
            if case .success(let p) = result { planets = p }
            group.leave()
        }

        group.enter()
        fetchEvents { result in
            if case .success(let e) = result { events = e }
            group.leave()
        }

        group.notify(queue: .main) {
            completion(picture, articles, planets, events)
        }
    }

    // MARK: - Livia Chat Assistant

    func fetchLiviaApiKey(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: graphqlEndpoint) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let query = """
        {
            "query": "{ apiKey(passphrase: \\"\(passphrase)\\") }"
        }
        """
        request.httpBody = query.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let dataObj = json["data"] as? [String: Any],
                   let apiKey = dataObj["apiKey"] as? String {
                    self?.liviaApiKey = apiKey
                    completion(true)
                } else {
                    completion(false)
                }
            } catch {
                completion(false)
            }
        }
        task.resume()
    }

    func sendMessageToLivia(message: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let apiKey = liviaApiKey else {
            // Try to fetch API key first
            fetchLiviaApiKey { [weak self] success in
                if success {
                    self?.sendMessageToLivia(message: message, completion: completion)
                } else {
                    completion(.failure(LegacyAPIError.noApiKey))
                }
            }
            return
        }

        guard let url = URL(string: chatEndpoint) else {
            completion(.failure(LegacyAPIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        // Build messages array with history
        var messages: [[String: String]] = [
            ["role": "system", "content": "You are a helpful assistant who will answer space/astronomy questions. Your name is Livia. You may answer any other questions. You are in an app called Cosmofy."]
        ]
        messages.append(contentsOf: chatHistory)
        messages.append(["role": "user", "content": message])

        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": messages,
            "temperature": 0.65,
            "stream": false
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(LegacyAPIError.noData))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let messageObj = firstChoice["message"] as? [String: Any],
                   let content = messageObj["content"] as? String {

                    // Add to history
                    self?.chatHistory.append(["role": "user", "content": message])
                    self?.chatHistory.append(["role": "assistant", "content": content])

                    completion(.success(content))
                } else {
                    completion(.failure(LegacyAPIError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    func clearChatHistory() {
        chatHistory.removeAll()
    }
}

// MARK: - Response Wrappers

private struct LegacyGraphQLResponse<T: Decodable>: Decodable {
    let data: T?
    let errors: [LegacyGraphQLError]?
}

private struct LegacyGraphQLError: Decodable {
    let message: String
}

private struct LegacyPictureResponse: Decodable {
    let picture: LegacyPicture
}

private struct LegacyArticlesResponse: Decodable {
    let articles: [LegacyArticle]
}

private struct LegacyPlanetsResponse: Decodable {
    let planets: [LegacyPlanet]
}

private struct LegacyEventsResponse: Decodable {
    let events: [LegacyEvent]
}

// MARK: - Data Models

struct LegacyPicture: Decodable {
    let date: String?
    let title: String?
    let credit: String?
    let copyright: String?
    let media: String?
    let media_type: String?
    let explanation: LegacyExplanation?
}

struct LegacyExplanation: Decodable {
    let original: String?
    let summarized: String?
    let kids: String?
}

struct LegacyArticle: Decodable {
    let month: Int?
    let year: Int?
    let title: String?
    let subtitle: String?
    let url: String?
    let source: String?
    let authors: [LegacyAuthor]?
    let banner: LegacyBanner?
}

struct LegacyAuthor: Decodable {
    let name: String?
    let title: String?
    let image: String?
}

struct LegacyBanner: Decodable {
    let image: String?
    let designer: String?
}

struct LegacyPlanet: Decodable {
    let id: Int?
    let name: String?
    let description: String?
    let expandedDescription: String?
    let facts: [String]?
    let visual: String?
    let moons: Int?
    let rings: Int?
    let mass: Double?
    let volume: Double?
    let density: Double?
    let temperature: Int?
    let escapeVelocity: Double?
    let gravityEquatorial: Double?
    let radiusEquatorial: Double?
    let albedo: Double?
    let orbitalVelocity: Double?
    let orbitalInclination: Double?
    let siderealOrbitPeriodY: Double?
    let solarDayLength: Double?
    let obliquityToOrbit: Double?
    let siderealRotationPeriod: Double?
    let flattening: Double?
    let pressure: Double?
    let atmosphere: [LegacyAtmosphereComponent]?
}

struct LegacyAtmosphereComponent: Decodable {
    let name: String?
    let molar: Int?
    let formula: String?
    let percentage: Double?
}

struct LegacyEvent: Decodable {
    let id: String
    let title: String?
    let categories: [LegacyCategory]?
    let sources: [LegacySource]?
    let geometry: [LegacyGeometry]?
}

struct LegacyCategory: Decodable {
    let id: String
    let title: String?
}

struct LegacySource: Decodable {
    let id: String
    let url: String?
}

struct LegacyGeometry: Decodable {
    let magnitudeValue: Double?
    let magnitudeUnit: String?
    let date: String?
    let type: String?
    let coordinates: [Double]?
}

// MARK: - Errors

enum LegacyAPIError: LocalizedError {
    case invalidURL
    case noData
    case httpError(Int)
    case graphQL([String])
    case invalidResponse
    case noApiKey

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .graphQL(let messages):
            return messages.joined(separator: "\n")
        case .invalidResponse:
            return "Invalid response format"
        case .noApiKey:
            return "Could not fetch Livia API key"
        }
    }
}
