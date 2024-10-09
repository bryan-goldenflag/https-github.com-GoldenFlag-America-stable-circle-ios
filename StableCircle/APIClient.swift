import Foundation
import os

class APIClient {
    static let shared = APIClient()
    private let baseURL = "http://localhost:3000/api/v1"
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "APIClient")
    
    func sendObject<T: Codable>(_ object: T, endpoint: String) async throws -> T {
        let url = URL(string: "\(baseURL)/\(endpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(object)
        
        logger.info("Sending POST request to \(url)")
        logger.debug("Request body: \(String(data: request.httpBody!, encoding: .utf8) ?? "")")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("Invalid response type received")
            throw APIError.invalidResponse
        }
        
        logger.info("Received response with status code: \(httpResponse.statusCode)")
        
        guard 200...299 ~= httpResponse.statusCode else {
            logger.error("Received error status code: \(httpResponse.statusCode)")
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        do {
            let decodedObject = try decoder.decode(T.self, from: data)
            logger.info("Successfully decoded response")
            logger.debug("Decoded object: \(String(describing: decodedObject))")
            return decodedObject
        } catch {
            logger.error("Decoding error: \(error.localizedDescription)")
            throw APIError.decodingError(error)
        }
    }
    
    func updateObject<T: Codable>(_ object: T, id: UUID, endpoint: String) async throws -> T {
        let url = URL(string: "\(baseURL)/\(endpoint)/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(object)
        
        logger.info("Sending PUT request to \(endpoint)/\(id)")
        logger.debug("Request body: \(String(data: request.httpBody!, encoding: .utf8) ?? "")")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("Invalid response type received")
            throw APIError.invalidResponse
        }
        
        logger.info("Received response with status code: \(httpResponse.statusCode)")
        
        guard 200...299 ~= httpResponse.statusCode else {
            logger.error("Received error status code: \(httpResponse.statusCode)")
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        do {
            let decodedObject = try decoder.decode(T.self, from: data)
            logger.info("Successfully decoded response")
            logger.debug("Decoded object: \(String(describing: decodedObject))")
            return decodedObject
        } catch {
            logger.error("Decoding error: \(error.localizedDescription)")
            throw APIError.decodingError(error)
        }
    }
    
    func fetchObject<T: Codable>(id: UUID, endpoint: String) async throws -> T {
        let url = URL(string: "\(baseURL)/\(endpoint)/\(id)")!
        
        logger.info("Sending GET request to \(endpoint)/\(id)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("Invalid response type received")
            throw APIError.invalidResponse
        }
        
        logger.info("Received response with status code: \(httpResponse.statusCode)")
        
        guard 200...299 ~= httpResponse.statusCode else {
            logger.error("Received error status code: \(httpResponse.statusCode)")
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        do {
            let decodedObject = try decoder.decode(T.self, from: data)
            logger.info("Successfully decoded response")
            logger.debug("Decoded object: \(String(describing: decodedObject))")
            return decodedObject
        } catch {
            logger.error("Decoding error: \(error.localizedDescription)")
            throw APIError.decodingError(error)
        }
    }
    
    func updateMessageStatus(_ messageId: UUID, status: MessageStatus) async throws {
        let statusData = ["status": status.rawValue]
        logger.info("Updating message status for message \(messageId) to \(status.rawValue)")
        _ = try await updateObject(statusData, id: messageId, endpoint: "messages/\(messageId)/status")
    }
}

enum APIError: Error {
    case invalidResponse
    case decodingError(Error)
}
