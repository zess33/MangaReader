import Foundation

public protocol NetworkManagerProtocol: Sendable {
    func request<T: Decodable>(_ endpoint: Endpoint, decoder: JSONDecoder) async throws -> T
    func requestData(_ endpoint: Endpoint) async throws -> Data
    func downloadImage(from url: URL) async throws -> Data
}
