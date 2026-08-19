import Foundation

/// Protocolo que define un Endpoint HTTP tipado.
public protocol Endpoint: Sendable {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: String]? { get }
    var body: Data? { get }
    var timeoutInterval: TimeInterval { get }
}

public extension Endpoint {
    var timeoutInterval: TimeInterval { 20.0 }
    var headers: [String: String]? { nil }
    var queryParameters: [String: String]? { nil }
    var body: Data? { nil }

    func makeURLRequest() throws -> URLRequest {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)
        
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            urlComponents?.queryItems = queryParameters.map { URLQueryItem(name: .key, value: .value) }
        }
        
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL(baseURL.absoluteString + "/" + path)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeoutInterval
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("MangaReader-iOS/1.0 (iPhone)", forHTTPHeaderField: "User-Agent")
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let body = body {
            request.httpBody = body
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        return request
    }
}

public struct AnyEndpoint: Endpoint, Sendable {
    public let baseURL: URL
    public let path: String
    public let method: HTTPMethod
    public let headers: [String: String]?
    public let queryParameters: [String: String]?
    public let body: Data?
    public let timeoutInterval: TimeInterval

    public init(
        baseURL: URL,
        path: String,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        queryParameters: [String: String]? = nil,
        body: Data? = nil,
        timeoutInterval: TimeInterval = 20.0
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headers = headers
        self.queryParameters = queryParameters
        self.body = body
        self.timeoutInterval = timeoutInterval
    }
}
