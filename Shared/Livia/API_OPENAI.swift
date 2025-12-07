/*
-----------------------------------------------------------------------------
File Name: API_OPENAI.swift
Description: Configures the request to OpenAI API and manages interactions
             with the API, including message sending and response handling.
-----------------------------------------------------------------------------
Creation Date: 10/21/23
-----------------------------------------------------------------------------
Author: Arryan Bhatnagar
Project: Cosmofy 4th Edition
-----------------------------------------------------------------------------
*/
 
 
/* MARK: imports */
import Foundation
import Combine

// Flag indicating whether AES decryption is complete
var AES_Complete: Bool = false

/* MARK: class InteractingViewModel
   ViewModel for interacting with the OpenAI API
 */

class InteractingViewModel: ObservableObject {
    
    @Published var isInteractingWithChatGPT = false
    @Published var messages: [MessageRow] = []
    @Published var inputMessage: String = ""
    
    private let api: API
    
    // Initialize the view model with an API instance
    init(api: API) {
        self.api = api
        
        messages.append(MessageRow(
            isInteractingWithChatGPT: false,
            sendImage: "openai",
            sendText: "Greetings from Livia! I can provide you with in-depth knowledge and insights about space like never before.",
            responseImage: "",
            responseText: nil,
            responseError: nil
        ))
    }
    
    // Handles the send button tap event by sending the input message.
    @MainActor
    func sendTapped() async {
        let text = inputMessage
        inputMessage = ""
        await send(text: text)
    }
    
    // Retries sending a previously sent message.
    // Parameter message: The message to be retried.
    @MainActor
    func retry(message: MessageRow) async {
        guard let index = messages.firstIndex(where: {$0.id == message.id}) else {
            return
        }

        // Refetch API key if needed before retrying
        await api.refetchApiKeyIfNeeded()

        self.messages.remove(at: index)
        await send(text: message.sendText)
    }
    
    // Sends a text message and updates the message list with the response.
    // Parameter text: The text to be sent.
    @MainActor
    func send(text: String) async {
        isInteractingWithChatGPT = true
        var streamText = ""
        var messageRow = MessageRow(
            isInteractingWithChatGPT: true, 
            sendImage: "user",
            sendText: text,
            responseImage: "livia",
            responseText: streamText,
            responseError: nil
        )
        
        self.messages.append(messageRow)
        
        do {
            let stream = try await api.sendMessageStream(text: text)
            for try await text in stream {
                streamText += text
                messageRow.responseText = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
                self.messages[self.messages.count - 1] = messageRow
            }
        } catch {
            messageRow.responseError = error.localizedDescription
        }
        
        messageRow.isInteractingWithChatGPT = false
        self.messages[self.messages.count - 1] = messageRow
        isInteractingWithChatGPT = false;
    }
}

/* MARK: class API
   API client for communicating with LiteLLM.
 */
class API: @unchecked Sendable {

    private let systemMessage: Message
    private let temperature: Double
    private let model: String

    private let graphqlEndpoint = "https://livia.arryan.xyz/graphql"
    private let chatEndpoint = "https://swift.arryan.xyz/v1/chat/completions"
    private let passphrase = "my-phone-passphrase"

    private var apiKey: String?
    private var historyList = [Message]()
    private let urlSession = URLSession.shared

    private var urlRequest: URLRequest {
        let url = URL(string: chatEndpoint)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        headers.forEach {
            urlRequest.setValue($1, forHTTPHeaderField: $0)
        }
        return urlRequest
    }

    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd"
        return df
    }()

    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()

    private var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey ?? "")"
        ]
    }

    init(model: String = "gpt-4o", systemPrompt: String = "You are a helpful assistant who will answer space/astronomy questions. Your name is Livia. You may answer any other questions. You are in an app called Cosmofy.", temperature: Double = 0.65) {
        self.model = model
        self.systemMessage = .init(role: "system", content: systemPrompt)
        self.temperature = temperature

        fetchApiKey { [weak self] fetchedApiKey in
            self?.apiKey = fetchedApiKey
            AES_Complete = true
            print("livia API key fetched: \(fetchedApiKey != nil)")
        }
    }

    // Refetches the API key if it's nil
    func refetchApiKeyIfNeeded() async {
        guard apiKey == nil else { return }
        await withCheckedContinuation { continuation in
            fetchApiKey { [weak self] fetchedApiKey in
                self?.apiKey = fetchedApiKey
                continuation.resume()
            }
        }
    }

    // Fetches the API key from GraphQL endpoint using passphrase
    private func fetchApiKey(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: graphqlEndpoint) else {
            completion(nil)
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

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Swift API key fetch error: \(error?.localizedDescription ?? "unknown")")
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let dataObj = json["data"] as? [String: Any],
                   let apiKey = dataObj["apiKey"] as? String {
                    print("livia API key received: \(apiKey.prefix(20))...")
                    completion(apiKey)
                } else {
                    print("livia API key: Invalid response format")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response: \(responseString)")
                    }
                    completion(nil)
                }
            } catch {
                print("livia API key JSON error: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    private func generateMessages(from text: String) -> [Message] {
        var messages = [systemMessage] + historyList + [Message(role: "user", content: text)]
        
        if messages.contentCount > (16000 * 4) {
            _ = historyList.removeFirst()
            messages = generateMessages(from: text)
        }
        return messages
        
    }
    
    func sendMessageStream(text: String) async throws -> AsyncThrowingStream<String, Error> {
        guard apiKey != nil else {
            throw APIError("API key not yet loaded. Please try again in a moment.")
        }
        var urlRequest = self.urlRequest
        urlRequest.httpBody = try jsonBody(text: text)
        
        let (result, response) = try await urlSession.bytes(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError("Invalid Response")
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            
            var errorText = ""
            for try await line in result.lines {
                errorText += line
            }
            
            if let data = errorText.data(using: .utf8), let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
                errorText = "\n\(errorResponse.message)"
            }
            throw APIError("Bad Response: \(httpResponse.statusCode), \(errorText)")

        }
        
        return AsyncThrowingStream<String, Error> {
            continuation in Task(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                do {
                    var responseText = ""
                    for try await line in result.lines {
                        if line.hasPrefix("data: "),
                           let data = line.dropFirst(6).data(using: .utf8),
                           let response = try? self.jsonDecoder.decode(StreamCompletionResponse.self, from: data),
                           let text = response.choices.first?.delta.content {
                            /* Haptics.shared.impact(for: .light)  */
                            responseText += text
                            continuation.yield(text)
                            /* Slows down each token by 2 ns */
                             
                            #if os(watchOS)
                            try await Task.sleep(nanoseconds: (10 + UInt64(Double.pi)) * 10000000)
                            #endif
                        }
                    }
                    self.appendToHistoryList(userText: text, responseText: responseText)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    func sendMessage(_ text: String) async throws -> String {
        guard apiKey != nil else {
            throw APIError("API key not yet loaded. Please try again in a moment.")
        }
        var urlRequest = self.urlRequest
        urlRequest.httpBody = try jsonBody(text: text, stream: false)
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError("Invalid Response")
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            var errorMessage = "Bad Response: \(httpResponse.statusCode)"
            if let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
                errorMessage.append("\n\(errorResponse.message)")
            }
            throw APIError(errorMessage)
        }
        
        do {
            let completionResponse = try self.jsonDecoder.decode(CompletionResponse.self, from: data)
            let responseText = completionResponse.choices.first?.message.content ?? ""
            self.appendToHistoryList(userText: text, responseText: responseText)
            return responseText
        } catch {
            throw error
        }
    }
    
    private func jsonBody(text: String, stream: Bool = true) throws -> Data {
        if (text.count > 40000) {
            throw APIError("Long Response: Max character limit of 40000")
        }
        
        let request = Request(model: model, temperature: temperature, messages: generateMessages(from: text), stream: stream)
        return try JSONEncoder().encode(request)
    }
    
    private func appendToHistoryList(userText: String, responseText: String) {
        self.historyList.append(.init(role: "user", content: userText))
        self.historyList.append(.init(role: "assistant", content: responseText))
    }
}

/* MARK: API Error */
struct APIError: LocalizedError {
    let message: String

    var errorDescription: String? { message }

    init(_ message: String) {
        self.message = message
    }
}

/* MARK: extension Data */
extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var byteLiteral = ""
        for (index, character) in hexString.enumerated() {
            byteLiteral.append(character)
            if index % 2 != 0 {
                guard let byte = UInt8(byteLiteral, radix: 16) else { return nil }
                data.append(byte)
                byteLiteral = ""
            }
        }
        self = data
    }
}

