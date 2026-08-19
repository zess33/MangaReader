import Foundation

/// Cliente de red asincrono desacoplado de las vistas.
public actor NetworkManager: NetworkManagerProtocol {
    public static let shared = NetworkManager()
    
    private let session: URLSession
    private let maxRetries: Int
    
    public init(session: URLSession = .shared, maxRetries: Int = 2) {
        self.session = session
        self.maxRetries = maxRetries
    }
    
    public func request<T: Decodable>(
        _ endpoint: Endpoint,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let data = try await executeWithRetry(endpoint: endpoint, retryCount: maxRetries)
        do {
            return try decoder.decode(T.self, from: data)
        } catch let DecodingError.dataCorrupted(context) {
            AppLogger.network.error("Decoding error (Data Corrupted): \(context.debugDescription)")
            throw NetworkError.decodingError("Datos corruptos: \(context.debugDescription)")
        } catch let DecodingError.keyNotFound(key, context) {
            AppLogger.network.error("Decoding error (Key Not Found '\(key.stringValue)'): \(context.debugDescription)")
            throw NetworkError.decodingError("Clave no encontrada '\(key.stringValue)': \(context.debugDescription)")
        } catch let DecodingError.typeMismatch(type, context) {
            AppLogger.network.error("Decoding error (Type Mismatch '\(type)'): \(context.debugDescription)")
            throw NetworkError.decodingError("Tipo incompatible '\(type)': \(context.debugDescription)")
        } catch let DecodingError.valueNotFound(value, context) {
            AppLogger.network.error("Decoding error (Value Not Found '\(value)'): \(context.debugDescription)")
            throw NetworkError.decodingError("Valor no encontrado '\(value)': \(context.debugDescription)")
        } catch {
            AppLogger.network.error("Decoding error: \(error.localizedDescription)")
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }
    
    public func requestData(_ endpoint: Endpoint) async throws -> Data {
        return try await executeWithRetry(endpoint: endpoint, retryCount: maxRetries)
    }
    
    public func downloadImage(from url: URL) async throws -> Data {
        let endpoint = AnyEndpoint(baseURL: url.deletingLastPathComponent(), path: url.lastPathComponent)
        return try await requestData(endpoint)
    }
    
    private func executeWithRetry(endpoint: Endpoint, retryCount: Int) async throws -> Data {
        var lastError: Error?
        
        for attempt in 0...retryCount {
            do {
                let request = try endpoint.makeURLRequest()
                AppLogger.network.debug("[\(request.httpMethod ?? "GET")] \(request.url?.absoluteString ?? "") (Intento \(attempt + 1))")
                
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 429:
                    let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap(TimeInterval.init)
                    AppLogger.network.warning("Rate limit 429. Reintentando...")
                    if attempt < retryCount {
                        let delay = retryAfter ?? Double(attempt + 1) * 2.0
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        continue
                    }
                    throw NetworkError.rateLimited(retryAfter: retryAfter)
                case 400...499:
                    AppLogger.network.error("Error cliente HTTP \(httpResponse.statusCode)")
                    throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
                case 500...599:
                    AppLogger.network.error("Error servidor HTTP \(httpResponse.statusCode)")
                    if attempt < retryCount {
                        let delay = Double(attempt + 1) * 1.5
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        continue
                    }
                    throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: "Error interno del servidor.")
                default:
                    throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
                }
            } catch let error as NetworkError {
                lastError = error
                if case .rateLimited = error, attempt < retryCount { continue }
                if case .serverError = error, attempt < retryCount { continue }
                throw error
            } catch let urlError as URLError {
                AppLogger.network.error("URLError: \(urlError.localizedDescription)")
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    throw NetworkError.noInternetConnection
                case .timedOut:
                    if attempt < retryCount { continue }
                    throw NetworkError.timeout
                default:
                    lastError = NetworkError.unknown(urlError.localizedDescription)
                }
            } catch {
                lastError = NetworkError.unknown(error.localizedDescription)
            }
        }
        
        throw lastError ?? NetworkError.unknown("Fallo de red inesperado tras varios reintentos.")
    }
}
