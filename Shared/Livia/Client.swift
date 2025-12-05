//
//  GraphQLClient.swift
//  Cosmofy
//
//  Created by Arryan Bhatnagar on 12/3/24.
//

import Foundation

// MARK: - GraphQL Client

class GraphQLClient {
    static let shared = GraphQLClient()

    private let endpoint = URL(string: "https://livia.arryan.xyz/graphql")!
    private let session = URLSession.shared

    private init() {}

    func execute<T: Decodable>(
        query: String,
        variables: [String: Any]? = nil
    ) async throws -> T {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = ["query": query]
        if let variables = variables {
            body["variables"] = variables
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GraphQLError.invalidResponse
        }

        guard 200...299 ~= httpResponse.statusCode else {
            throw GraphQLError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        let graphQLResponse = try decoder.decode(GraphQLResponse<T>.self, from: data)

        if let errors = graphQLResponse.errors, !errors.isEmpty {
            throw GraphQLError.graphQL(errors.map { $0.message })
        }

        guard let data = graphQLResponse.data else {
            throw GraphQLError.noData
        }

        return data
    }
}

// MARK: - Response Wrapper

struct GraphQLResponse<T: Decodable>: Decodable {
    let data: T?
    let errors: [GraphQLErrorDetail]?
}

struct GraphQLErrorDetail: Decodable {
    let message: String
}

// MARK: - Errors

enum GraphQLError: LocalizedError {
    case invalidResponse
    case httpError(Int)
    case graphQL([String])
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .graphQL(let messages):
            return messages.joined(separator: "\n")
        case .noData:
            return "No data returned"
        }
    }
}
